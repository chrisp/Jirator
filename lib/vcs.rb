require File.join(File.dirname(__FILE__), 'svn_driver.rb')

class Vcs
  attr_accessor :driver

  def initialize(options={})
    self.driver = VcsDriver.const_get(options[:driver].to_s.capitalize).new(options)
  end

  def log(limit=nil)
    driver.log(limit)
  end
end