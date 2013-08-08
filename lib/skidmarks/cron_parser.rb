module CronParser
  require 'active_support/core_ext/numeric'
  require 'json'

  class Crontab
    attr_reader :jobs

    def initialize(options={})
      @earliest_time = options[:earliest_time]
      @latest_time   = options[:latest_time]
      @input         = options[:input]

      prepare_event_data options[:event_data]

      @jobs = []
      get_lines { |line| @jobs << line_to_jobs(line) }
    end

    # Find out how many minutes there are between the two times user specified
    # so that CronJob can roll up every-X-minute jobs even for unusual periods.
    def prepare_event_data event_data
      # Subtracting a minute from @earliest_time via - 60 because
      # we're not trying to determine a difference between two times,
      # but rather a duration across them, so avoid the off-by-one.
      # That is, 1:05 - 1:01 gives us :04, when really there are 5
      # whole minutes to consider, since execution happens at the
      # start of each -- :01, :02, :03, :04, :05.
      num_minutes = (((Time.parse(@latest_time)) - (Time.parse(@earliest_time) - 60)) / 60).to_i

      # Minutes is easy because it's cron's finest level of granularity.
      # Five minutes is a bit different since cron doesn't fire,
      # e.g. "every five minutes" so much as "on the minutes marked
      # :00, :05, :10", etc. So if user has passed in a
      # non-evenly-divisible start or start period, we have to know
      # not the quantity of minutes contained, but which particular
      # intervals are inside the earliest/latest times. We get this
      # by doing a mini-cronparse call for */5 minutes.
      h = Hash.new.tap do |h|
        h[:mi] = CronParser.expand(:mi, "*/5")
        [:ho, :da, :mo, :dw].each do |k| # * the remaining fields.
          h[k] = CronParser.expand(k, "*")
        end
      end
      num_five_minutes = fan_out(h).size

      # We now know how many minute and five-minute intervals are in
      # the user's selected period. Merge that in event_data so that
      # we can roll these periods up along with whatever custom
      # settings they've defined.
      @event_data = event_data.merge(num_minutes      => event_data[:every_minute],
                                     num_five_minutes => event_data[:every_five_minutes])
    end

    def get_lines
      @input.each_line do |x|
        yield x.chop if x.strip.match /^[\*0-9]/
      end
    end

    # Turn a cronjob line into a command and list of occurring times.
    def line_to_jobs line
      elements = {}

      # minute hour day month dayofweek command
      mi, ho, da, mo, dw, *co = line.split
      {:mi => mi, :ho => ho, :da => da, :mo => mo, :dw => dw}.each_pair do |k, v|
        elements[k] = CronParser.expand(k, v)
      end

      CronJob.new(:command => co, :times => fan_out(elements), :event_data => @event_data, :cron_string => [mi, ho, da, mo, dw].join(" "))
    end

    # Accept a blueprint of a job as an exploded list of time elements,
    # and return any qualifying times as Time objects.
    # minutes=[15,45] hours=[4] => [Time(4:15), Time(4:45)]
    # day-of-week is a filter on top of the day field, so we filter by
    # it but do not iterate over it.
    def fan_out els
      good = []

      # "2011-...", "2011-..." => [2011]
      years = (@earliest_time.split("-")[0].to_i..@latest_time.split("-")[0].to_i).to_a

      years.each do |ye|
        els[:mo].each do |mo|
          els[:da].each do |da|
            els[:ho].each do |ho|
              els[:mi].each do |mi|
                good << Time.parse("#{ye}-#{mo}-#{da} #{ho}:#{mi}") if date_in_bounds?(ye, mo, da, ho, mi)
              end
            end
          end
        end
      end
      apply_weekday_filter(good, els[:dw])
    end

    def date_in_bounds? ye, mo, da, ho, mi
      # Comparing dates element-wise in string form turns out to be
      # like 6x faster than casting to DateTime objects first... so, don't.
      date = "%s-%02d-%02d %02d:%02d" % [ye, mo, da, ho, mi]
      @earliest_time <= date and date <= @latest_time
    end

    def apply_weekday_filter dates, filter
      # Avoid comparison if we can.
      dates.reject! {|d| !filter.include? d.wday } unless filter.size == 7
      dates
    end

    def to_json(*a)
      events = []
      @jobs.sort_by{|j| j.events.size}.reverse.each do |job|
        job.events.each do |event|
          events << (event.merge({"trackNum" => job.track_number}))
        end
      end
      {"dateTimeFormat" => "iso8601", "events" => events.sort_by {|x| x['caption']}}.to_json
    end
  end

  private

  class CronJob
    attr_reader :events, :command, :times

    DEFAULT_DURATION = 40.seconds

    def initialize options
      @times      = options[:times]
      @command    = options[:command]
      @event_data = options[:event_data]
      merge_event_data options
    end

    def merge_event_data options
      @events = []

      if @event_data.keys.include? options[:times].size
        # Rollup */1 and */5 jobs into a single job for display purposes.
        seed = @event_data[options[:times].size]
        data = {
            "start"       => options[:times][0].iso8601,
            "end"         => options[:times][-1].iso8601,
            "caption"       => "#{seed['title_prefix']}#{@command}",
            "description" => "#{seed['title_prefix']}#{@command}",
            "cron" => options[:cron_string],
        }
        @events = [@event_data[:default].merge(seed).merge(data)]
        @@additional_event_data[@command] = {}
        @@additional_event_data[@command]["count"] = 1000000000000
        @@reserved_slots += 1
        @@additional_event_data[@command]["track_number"] = @@reserved_slots
      else
        options[:times].each do |time|
          data = {
              "start"       => time.iso8601,
              "end"         => (time + DEFAULT_DURATION).iso8601,
              "caption"     => "%02d:%02d %s" % [time.hour, time.min, @command],
              "description" => @command,
              "cron"        => options[:cron_string]
          }
          fill_additional_event_data
          @events << @event_data[:default].merge(data).merge(@@additional_event_data[@command])
        end
      end
    end

    def track_number
      return @@additional_event_data[@command]["track_number"] unless @@additional_event_data[@command]["track_number"].nil?
      if @events.size < 5
        @@additional_event_data[@command]["track_number"] = find_last_track_number
      else
        @@additional_event_data[@command]["track_number"] = calculate_track_number if @@additional_event_data[@command]["track_number"].nil?
        @@additional_event_data[@command]["track_number"]
      end
    end

    def self.reset_state
      @@jobs = 0
      @@additional_event_data = {}
      @@reserved_slots = 0
      @@last_track_number = nil
    end

  private

    def calculate_track_number
      sorted_by_count = @@additional_event_data.sort_by{ |k, _| @@additional_event_data[k]["count"] }.reverse
      sorted_by_count.find_index([@command, @@additional_event_data[@command]]) + 1
    end

    def find_last_track_number
      if @@last_track_number.nil?
        @@last_track_number = @@additional_event_data.values.sort_by{|v| v["track_number"].nil?? -1 : v["track_number"]}[-1]['track_number'] + @@reserved_slots
      end
      @@last_track_number
    end

    COLORS = %w(#FF0000 #00FFFF #C0C0C0 #0000FF #808080 #0000A0 #000000 #ADD8E6 #FFA500 #800080 #A52A2A #FFFF00 #800000 #00FF00 #008000 #FF00FF #808000)
    @@jobs = 0
    @@additional_event_data = {}
    @@reserved_slots = 0
    @@last_track_number = nil

    def fill_additional_event_data
      data = @@additional_event_data[@command]
      if (data.nil?)
        data = {}
        data["color"] = COLORS[(@@jobs.divmod(COLORS.size))[1]]
        data["count"] = 1
        @@additional_event_data[@command] = data
        @@jobs += 1
      else
        data["count"] = data["count"] + 1
      end
    end
  end

  class CronParser
    # Syntax respected:
    # N      Integer
    # N,N,N  Set
    # N-N    Range inclusive
    # *      All
    # */N    Every N
    def self.expand field, interval
      case
        when interval == interval[/\d+/]
          [interval.to_i]
        when interval[/,/]
          interval.split(",").map(&:to_i)
        when interval[/-/]
          start, stop = interval.split("-").map(&:to_i)
          start.step(stop).to_a
        else
          expand_recurring field, interval
      end
    end

    def self.expand_recurring field, interval
      if interval == '*'
        interval = 1
      else
        interval = interval[/\d+/].to_i
      end
      case field
        when :mi then 0.step(59, interval)
        when :ho then 0.step(23, interval)
        when :da then 1.step(31, interval)
        when :mo then 1.step(12, interval)
        when :dw then 0.step(6,  interval)
      end.to_a
    end
  end
end
