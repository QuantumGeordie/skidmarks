module Skidmarks
  @scheduler_file_location = nil

  def self.scheduler_file_location=(location)
    @scheduler_file_location = location
  end

  def self.scheduler_file_location
    @scheduler_file_location
  end
end
