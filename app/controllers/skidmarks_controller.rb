class SkidmarksController < ApplicationController
  before_filter :get_gem_version

  def index


  end


  private

  def get_gem_version
    @skidmards_gem_version = Gem.loaded_specs['skidmarks'].version.to_s
  end
end
