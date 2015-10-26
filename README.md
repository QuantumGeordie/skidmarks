# Skidmarks

backup job schedule visualization tool

## Travis-ci

[![Build Status](https://travis-ci.org/QuantumGeordie/skidmarks.png)](https://travis-ci.org/QuantumGeordie/skidmarks)

## Installation

Add this line to your application's Gemfile:

    gem 'skidmarks', :git => 'git://github.com/quantumGeordie/skidmarks.git'

And then execute:

    $ bundle

someday you will be able to install it yourself like this:

    $ gem install skidmarks

## Usage

with gem in project, initialize the scheduler file location like:

    Skidmarks.scheduler_file_location = '/path/to/your/file.yml'

or with a dynamic configuration, e.g.:

    Skidmarks.scheduler_file_location = Rails.root.join('config', 'scheduler.yml')

then visit `/skidmarks` in your application.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
