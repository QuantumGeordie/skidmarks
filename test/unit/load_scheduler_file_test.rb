require 'unit_test_helper'

class TestLoadSchedulerFile < ActiveSupport::TestCase
  include Skidmarks
  include FileGenerators

  def teardown
    clear_test_files
  end

  def test_parse_from_file
    scheduler_file = File.expand_path('../../test_app_3_2/config/scheduler.yml', __FILE__)

    assert File.exist?(scheduler_file), "Expected scheduler_file [#{scheduler_file}] to exist."

    Skidmarks.scheduler_file_location = scheduler_file
    crontab_data = Skidmarks.generate_crontab_data_from_file.split("\n")

    assert_equal 9, crontab_data.length, 'number of crontab entries in file'
  end

  def test_parse_simple_file
    file_generated = make_scheduler_file_1_job('Single Job', '* * * * *', {'other_stuff' => 'booty', 'really_lame_stuff' => 'modern country music'})
    assert File.exist?(file_generated), 'file should have been created by helper method.'

    Skidmarks.scheduler_file_location = file_generated
    crontab_data = Skidmarks.generate_crontab_data_from_file.split("\n")

    assert_equal 1, crontab_data.length, 'number of crontab entries in file'
  end

  def test_parse_simple_long_file
    file_generated = make_scheduler_file_n_jobs(12)
    assert File.exist?(file_generated), 'file should have been created by helper method.'

    Skidmarks.scheduler_file_location = file_generated
    crontab_data = Skidmarks.generate_crontab_data_from_file.split("\n")

    assert_equal 12, crontab_data.length, 'number of crontab entries in file'
  end

  private


end

