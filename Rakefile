require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'engine_cart/rake_task'

task default: :ci
RSpec::Core::RakeTask.new

Dir.glob('lib/tasks/*.rake').each { |r| import r }

desc 'Continuous Integration (generate test app and run tests)'
task ci: ['engine_cart:generate', 'spec'] do
end
