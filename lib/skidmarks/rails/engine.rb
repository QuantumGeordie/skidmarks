module Skidmarks
  class Engine < ::Rails::Engine
    initializer "skidmarks.assets.precompile" do |app|
      app.config.assets.precompile += ['skidmarks.css']
    end
  end
end