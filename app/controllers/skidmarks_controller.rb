class SkidmarksController < ApplicationController
  require 'time'

  include Skidmarks

  before_filter :get_gem_version

  def index
    @start_time = "#{Time.now.strftime('%F')} 00:00"
    @end_time   = "#{Time.now.strftime('%F')} 23:59"

    Skidmarks.generate_crontab_data_from_file
    @jobs = Skidmarks.jobs(@start_time, @end_time)
  end

  private

  def get_gem_version
    @skidmarks_gem_version = Gem.loaded_specs['skidmarks'].version.to_s
  end
end
