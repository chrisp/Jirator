require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'vcs.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'jirate.rb'))

describe Vcs do
  # Add additional drivers here (they should all have matching functionality)
  [:svn].each do |driver|
    context "#{driver} driver" do
      before(:each) do
        @jirate = Jirate.new
        @vcs = Vcs.new({
          :driver => driver,
          :user => @jirate.conf['vcs_user'],
          :password => @jirate.conf['vcs_password'],
          :url => @jirate.conf['repository'],
          :working_copy => @jirate.conf["working_copy"]
        })
      end

      describe "log" do
        it "should return the log from #{driver}" do
          results = @vcs.log
          # TODO - add more assertions
          results.should_not be_empty
        end
      end

      describe "log(1)" do
        it "should return the most recent log" do
          results = @vcs.log(1)
          # TODO - add more assertions
          results.should_not be_empty
        end
      end
    end
  end
end
