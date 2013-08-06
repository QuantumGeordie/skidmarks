require 'unit_test_helper'

class TestLoadSchedulerFile < ActiveSupport::TestCase

  include Skidmarks

  def test_version
    assert_match Gem.loaded_specs['skidmarks'].version.to_s, Skidmarks::VERSION
  end

  def test_parse_from_file


  end

end

