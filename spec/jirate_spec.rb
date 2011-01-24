require File.join(File.dirname(__FILE__), '..', 'lib', 'jirate.rb')

def most_recent_jira_revision
  `geera list all | tail -1 | awk '{print$1}'`.split('-').last.to_i
end

describe Jirate do
  before(:each) do
    @jirate = Jirate.new
    # @current_rev = @current_rev.nil? ? most_recent_jira_revision : (@current_rev + 1)
    @current_rev = 11
  end

  context 'User marks ticket resolved' do
    describe 'shake' do
      it 'should resolve the ticket in Jira' do
        system("cd #{@jirate.conf['working_copy']} && echo 'your face' >> tmp")
        system("cd #{@jirate.conf['working_copy']} && svn ci -m 'fix FF-#{@current_rev}'")

        @jirate.shake
        # Assert
      end
    end
  end
end
