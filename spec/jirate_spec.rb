require File.join(File.dirname(__FILE__), '..', 'lib', 'jirate.rb')

describe Jirate do
  before(:each) do
    @jirate = Jirate.new
    @ticket = 'SVNIT-1'
  end

  context 'User changes ticket workflow' do
    ['stop', 'stop_uat', 'start_uat', 'start_qat', 'start'].each do |action|
      describe "#{action}(ticket)" do
        it "should #{action.gsub('_', ' ')} for the ticket" do
          @jirate.send(action, @ticket)
          # ASSERTS
        end
      end
    end
  end

  describe 'assign(ticket, chrphillips)' do
    it 'should assign the ticet to the chrphillips' do
      @jirate.assign(@ticket, 'chrphillips')
    end
  end

  describe 'assign(ticket, kmcclusky)' do
    it 'should assign the ticet to the kmcclusky' do
      @jirate.assign(@ticket, 'kmcclusky')
    end
  end
end
