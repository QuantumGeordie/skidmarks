module Skidmarks
  require 'erb'
  require 'yaml'
  require 'time'
  require 'active_support/core_ext/numeric'

  EVENT_DATA = {
      :default            => { "textColor" => "#000000", "classname" => "default", "durationEvent" => true},
      :every_minute       => { "title_prefix" => "Every minute: ", "color" => "#f00", "durationEvent" => true},
      :every_five_minutes => { "title_prefix" => "Every five minutes: ", "color" => "#fa0", "durationEvent" => true}
  }

  def self.generate_crontab_data
    raw_str = File.read(Skidmarks.scheduler_file_location)
    yaml_str = ERB.new(raw_str).result
    config = YAML.load(yaml_str)

    crontab_data = []
    config.keys.each { |key| crontab_data << "#{config[key]['cron_schedule']} #{key}" }

    crontab_data.join("\n")
  end

  def self.jobs(start_time, end_time)
    input_data = Skidmarks.generate_crontab_data
    CronParser::CronJob.reset_state
    jobs = CronParser::Crontab.new(:earliest_time => start_time,
                                   :latest_time   => end_time,
                                   :event_data    => EVENT_DATA,
                                   :input         => input_data)
    jobs.to_json.html_safe
  end
end
