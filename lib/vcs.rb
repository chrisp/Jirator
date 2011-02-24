require File.join(File.dirname(__FILE__), 'svn_driver.rb')

class Vcs
  attr_accessor :driver

  def initialize(options={})
    self.driver = VcsDriver.const_get(options[:driver].to_s.capitalize).new(options)
  end

  def log(limit=nil)
    logs = driver.log(limit).split('------------------------------------------------------------------------').reject do |l|
       l == "" || l == "\n"
    end

    logs.size == 1 ? logs.first : logs
  end
end