class SkidmarksController < ApplicationController
  require 'time'
  # include Skidmarks

  before_filter :get_gem_version

  EVENT_DATA = {
      :default => { "textColor" => "#000000", "classname" => "default", "durationEvent" => true},
      :every_minute => { "title_prefix" => "Every minute: ", "color" => "#f00", "durationEvent" => true},
      :every_five_minutes => { "title_prefix" => "Every five minutes: ", "color" => "#fa0", "durationEvent" => true}
  }


  def index
    @start_time = "2013-07-23 00:00"
    @end_time = "2013-07-23 23:59"

    @jobs = CronParser::Crontab.new(:earliest_time => @start_time, :latest_time => @end_time, :event_data => EVENT_DATA, :input => generate_crontab_data).to_json
    puts @jobs
    @jobs.html_safe
  end


  private

  def generate_crontab_data
    config = YAML::load_file(Skidmarks.scheduler_file_location)
    s = ''
    config.keys.each do |key|
      s += (config[key]['cron_schedule'] + " " + key + "\n")
    end
    s
  end

  def get_gem_version
    @skidmarks_gem_version = Gem.loaded_specs['skidmarks'].version.to_s
  end
end
