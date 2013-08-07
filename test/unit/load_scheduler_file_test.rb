require 'unit_test_helper'

class TestLoadSchedulerFile < ActiveSupport::TestCase
  include Skidmarks
  include FileGenerators

  def teardown
    clear_test_files
  end

  def test_version
    assert_match Gem.loaded_specs['skidmarks'].version.to_s, Skidmarks::VERSION
  end

  def test_parse_from_file
    scheduler_file = File.expand_path('../../test_app_3_2/config/scheduler.yml', __FILE__)

    assert File.exist?(scheduler_file), "Expected scheduler_file [#{scheduler_file}] to exist."

    Skidmarks.scheduler_file_location = scheduler_file
    crontab_data = Skidmarks.generate_crontab_data.split("\n")

    assert_equal 9, crontab_data.length, 'number of crontab entries in file'
  end

  def test_parse_simple_file
    file_generated = make_scheduler_file_1_job({'other_stuff' => 'booty', 'really_lame_stuff' => 'modern country music'})
    assert File.exist?(file_generated), 'file should have been created by helper method.'

    Skidmarks.scheduler_file_location = file_generated
    crontab_data = Skidmarks.generate_crontab_data.split("\n")

    assert_equal 1, crontab_data.length, 'number of crontab entries in file'
  end

  private

  def clear_test_files
    if File.exist? FileGenerators::TEMP_FILE_PATH
      Dir[File.join(FileGenerators::TEMP_FILE_PATH, "*.yml")].each { |f| FileUtils.rm_rf f }
      Dir.delete(FileGenerators::TEMP_FILE_PATH)
    end
  end


end

