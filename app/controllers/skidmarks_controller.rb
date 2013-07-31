class SkidmarksController < ApplicationController
  before_filter :get_gem_version

  def index
  	@jobs = [{:name => 'job 1', :cron => '* * * 10 20', :class => 'Array', :method => 'join', :args => [1,2], :for_each_vhost => true}, {:name => 'job 2', :cron => '15/3 * * 10 20', :class => 'Hash', :method => 'concat', :args => ['a', 'b'], :for_each_vhost => false}]

  end


  private

  def get_gem_version
    @skidmarks_gem_version = Gem.loaded_specs['skidmarks'].version.to_s
  end
end
