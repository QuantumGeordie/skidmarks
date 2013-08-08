require 'unit_test_helper'

class TestPlottableData < ActiveSupport::TestCase
  include Skidmarks
  include FileGenerators
  require 'active_support/core_ext/numeric'

  def teardown
    clear_test_files
  end

  def test_single_job_data
    file = make_scheduler_file_1_job("12345678901234567890", "*/10 * * * *")
    Skidmarks.scheduler_file_location = file
    Skidmarks.generate_crontab_data_from_file

    start_time = "#{Time.now.strftime('%F')} 00:00"
    end_time   = "#{Time.now.strftime('%F')} 23:59"

    Skidmarks.generate_crontab_data_from_file
    plottable_jobs_json = Skidmarks.jobs(start_time, end_time)

    plottable_jobs_hash = JSON.parse(plottable_jobs_json)

    assert_match 'iso8601', plottable_jobs_hash['dateTimeFormat']
    assert_equal 144, plottable_jobs_hash['events'].length

    date_check_start = Time.parse(start_time)
    plottable_jobs_hash['events'].each do |event|
      event_start = event['start']
      event_start_expected = date_check_start.strftime("%FT%T") + date_check_start.strftime("%z").insert(-3, ':')

      assert_match event_start_expected, event_start, 'event start time should be every 10 minutes'
      assert_equal event['trackNum'],    1,           'all events from the same, single job should be in track 1'

      date_check_start = date_check_start + 10.minutes
    end

  end

end
