require 'yaml'

class Jirate
  attr_accessor :conf
  
  def initialize
    self.conf = YAML::load(File.join(File.dirname(__FILE__), '..', 'jirate.conf'))
  end
  
  def shake
    system "cd #{self.conf[:working_copy]}"
  end
end