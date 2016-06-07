begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'engine_cart/rake_task'

Bundler::GemHelper.install_tasks

task default: :spec
RSpec::Core::RakeTask.new

import './tasks/noid_tasks.rake'
