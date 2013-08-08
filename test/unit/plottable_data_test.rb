require 'unit_test_helper'

class TestPlottableData < ActiveSupport::TestCase
  include Skidmarks
  include FileGenerators
  require 'active_support/core_ext/numeric'

  def teardown
    clear_test_files
  end

  def test_single_job_data
    job_name = 'The Big Job'
    file = make_scheduler_file_1_job(job_name, "*/10 * * * *")
    Skidmarks.scheduler_file_location = file
    Skidmarks.generate_crontab_data_from_file

    start_time = "#{Time.now.strftime('%F')} 00:00"
    end_time   = "#{Time.now.strftime('%F')} 23:59"

    Skidmarks.generate_crontab_data_from_file
    plottable_jobs_json = Skidmarks.jobs(start_time, end_time)

    plottable_jobs_hash = JSON.parse(plottable_jobs_json)

    assert_equal 'iso8601', plottable_jobs_hash['dateTimeFormat']
    assert_equal 144,       plottable_jobs_hash['events'].length

    date_check_start = Time.parse(start_time)
    plottable_jobs_hash['events'].each do |event|
      event_start = event['start']
      event_start_expected = date_check_start.strftime("%FT%T%z").insert(-3, ':')

      assert_equal event_start_expected,           event_start, 'event start time should be every 10 minutes'
      assert_equal event['trackNum'],              1,           'all events from the same, single job should be in track 1'
      assert_equal event['description'].join(' '), job_name,    'the job name'

      date_check_start = date_check_start + 10.minutes
    end
  end

  def test_single_job__odd_format
    job_name = 'The Big Job'
    file = make_scheduler_file_1_job(job_name, "12,45 */3 * * *")
    Skidmarks.scheduler_file_location = file
    Skidmarks.generate_crontab_data_from_file

    start_time = "#{Time.now.strftime('%F')} 00:00"
    end_time   = "#{Time.now.strftime('%F')} 23:59"

    Skidmarks.generate_crontab_data_from_file
    plottable_jobs_json = Skidmarks.jobs(start_time, end_time)

    plottable_jobs_hash = JSON.parse(plottable_jobs_json)

    assert_equal 'iso8601', plottable_jobs_hash['dateTimeFormat']
    assert_equal 16,        plottable_jobs_hash['events'].length

    plottable_jobs_hash['events'].each do |event|
      assert_equal event['trackNum'],              1,           'all events from the same, single job should be in track 1'
      assert_equal event['description'].join(' '), job_name,    'the job name'
    end
  end

  def test_multiple_job_data
    job_names = ['job 1', 'job 2', 'job 3']
    job_crons = ["*/10 * * * *", "*/20 * * * *", "12,45 */3 * * *"]
    file = make_scheduler_file_multiple_jobs(job_names, job_crons)

    start_time = "#{Time.now.strftime('%F')} 00:00"
    end_time   = "#{Time.now.strftime('%F')} 23:59"

    Skidmarks.generate_crontab_data_from_file
    plottable_jobs_json = Skidmarks.jobs(start_time, end_time)

    plottable_jobs_hash = JSON.parse(plottable_jobs_json)

    assert_equal 'iso8601', plottable_jobs_hash['dateTimeFormat']

    job_events = []
    events_count = 0
    job_names.each do |job_name|
      job_events << plottable_jobs_hash['events'].select { |event| event['description'].join(' ') == job_name }
      events_count += job_events.last.length
    end
    #job_events << plottable_jobs_hash['events'].select { |event| event['trackNum'] == 1 }
    #job_events << plottable_jobs_hash['events'].select { |event| event['trackNum'] == 2 }
    #events_count = job_events[0].length + job_events[1].length

    assert_equal 144, job_events[0].length
    assert_equal 72,  job_events[1].length
    assert_equal 16,  job_events[2].length

    assert_equal events_count, plottable_jobs_hash['events'].length

    job_events[0].each { |event| assert_equal 1, event['trackNum'], "track number for events in #{job_names[0]}" }
    job_events[1].each { |event| assert_equal 2, event['trackNum'], "track number for events in #{job_names[1]}" }
    job_events[2].each { |event| assert_equal 3, event['trackNum'], "track number for events in #{job_names[2]}" }

  end

end
