#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'jirate.rb'))
jirator = Jirate.new

loop do
  jirator.shake
  sleep(3)
end

