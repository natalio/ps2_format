# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'



Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

task :default => :test