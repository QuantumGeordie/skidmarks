# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skidmarks/version'

Gem::Specification.new do |spec|
  spec.name          = "skidmarks"
  spec.version       = Skidmarks::VERSION
  spec.authors       = ["geordie", "johannes"]
  spec.email         = ["george.speake@gmail.com"]
  spec.description   = %q{Skidmarks shows you where you did your duty}
  spec.summary       = %q{use Skidmarks to parse and display a yaml shceduler file to make sure your jobs are scheduled when you intended}
  spec.homepage      = "https://github.com/QuantumGeordie/skidmarks"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
