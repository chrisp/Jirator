#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

exec = File.expand_path(File.join(File.dirname(__FILE__), 'jirator.rb'))
Daemons.run(exec)