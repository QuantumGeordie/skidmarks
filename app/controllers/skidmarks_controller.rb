class SkidmarksController < ApplicationController
  require 'time'

  before_filter :get_gem_version

  EVENT_DATA = {
      :default => { "color" => "#7FFFD4", "textColor" => "#000000", "classname" => "default", "durationEvent" => false},
      :every_minute => { "title_prefix" => "Every minute: ", "color" => "#f00", "durationEvent" => true},
      :every_five_minutes => { "title_prefix" => "Every five minutes: ", "color" => "#fa0", "durationEvent" => true}
  }


  def index
    @start_time = "2013-07-23 00:00"
    @end_time = "2013-07-23 23:59"

    @jobs = CronParser::Crontab.new(:earliest_time => @start_time, :latest_time => @end_time, :event_data => EVENT_DATA, :input => generate_crontab_data).to_json
    puts @jobs
    @jobs
  end


  private

  def generate_crontab_data
    config = YAML::load_file(Rails.root + 'config/scheduler.yml')
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
