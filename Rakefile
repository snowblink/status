# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "update_status"
  gem.homepage = "http://github.com/dougdroper/status"
  gem.license = "MIT"
  gem.summary = %Q{Status update for pull requests}
  gem.description = %Q{Updates pull requests on github, with latest build from Jenkins and QA status}
  gem.email = "douglasroper@notonthehighstreet.com"
  gem.authors = ["Douglas Roper"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


task :default => :test

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec