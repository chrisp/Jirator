require File.join(File.dirname(__FILE__), '..', 'lib', 'jirate.rb')
require 'ostruct'

describe Jirate do
  before(:each) do
    @jirate = Jirate.new
    @ticket = 'SVNIT-1'
    @available_actions = []

    [{
      :name => 'start_dev',
      :id => 11},{
      :name => 'stop_dev',
      :id => 21},{
      :name => 'start_qat',
      :id => 31},{
      :name => 'stop_qat',
      :id => 61},{
      :name => 'start_uat',
      :id => 71},{
      :name => 'stop_uat',
      :id => 91},{
      :name =>  'close',
      :id => 101},{
      :name => 'reopen',
      :id => 131}].each do |action|
        obj = Object.new
        obj.stub!(:name).and_return(action[:name])
        obj.stub!(:id).and_return(action[:id])
        @available_actions << obj
      end

  end

  context 'user changes ticket workflow' do
    ['stop_dev', 'stop_uat', 'start_uat', 'start_qat', 'start_dev'].each do |action|
      describe "#{action}(ticket)" do
        it "should #{action.gsub('_', ' ')} for the ticket" do
          @jirate.send(action, @ticket)
          @jirate.jira.getAvailableActions(@ticket).map {|a| a.id.to_i}.include?(
            @jirate.conf['actions'][action]['id']).should be_false
        end
      end
    end

    it "should not set to a workflow that is already set" do
      @jirate.start_dev(@ticket, false)
      @jirate.jira.should_not_receive(:progressWorkflowAction)
      @jirate.start_dev(@ticket, false)
      @jirate.jira.getAvailableActions(@ticket).map {|a| a.id.to_i}.include?(
        @jirate.conf['actions']['start_dev']['id']).should be_false
    end

    it "should progress through fallback actions if action is not allowed" do
      @jirate.start_uat(@ticket)
      @jirate.jira.getAvailableActions(@ticket).map {|a| a.id.to_i}.include?(
        @jirate.conf['actions']['start_uat']['id']).should be_false
      @jirate.conf['actions']['start_uat']['fallbacks'].each do |fallback|
        @jirate.jira.getAvailableActions(@ticket).map {|a| a.id.to_i}.include?(
          @jirate.conf['actions'][fallback]['id']).should be_false
      end
      @jirate.stop_uat(@ticket)
      @jirate.stop_dev(@ticket)
    end
  end

  context 'assigning users' do
    describe 'assign(ticket, chrphillips)' do
      xit 'should assign the ticket to the chrphillips' do
        @jirate.assign(@ticket, 'chrphillips')
        @jirate.jira.getIssue(@ticket).assignee.should == 'chrphillips'
      end
    end

    describe 'assign(ticket, kmcclusky)' do
      xit 'should assign the ticket to the kmcclusky' do
        @jirate.assign(@ticket, 'kmcclusky')
        @jirate.jira.getIssue(@ticket).assignee.should == 'kmcclusky'
      end
    end
  end

  context 'time tracking' do
    describe 'add_time(ticket, time)' do
      it 'should add time amount of time' do
        @jirate.add_time(@ticket, '2h')
      end
    end
  end

  context 'comment parsing' do
    describe 'shake' do
      before(:each) do
        @jirate.vcs = OpenStruct.new
      end

      it 'should not do anything if only a ticket number is present' do
        @jirate.vcs.should_receive(:log).and_return("#{@ticket}")
        @jirate.should_not_receive(:assign)

        @jirate.conf['actions'].each do |action, action_id|
          @jirate.should_not_receive(action)
        end

        @jirate.shake
      end

      it 'should assign to user if ticket and assign keyword are present' do
        @jirate.vcs.should_receive(:log).and_return("#{@ticket} assign kmcclusky")
        @jirate.should_receive(:assign).with(@ticket, 'kmcclusky').and_return(true)
        @jirate.shake
      end

      it 'should assign to user if ticket and assign keyword are present with blabber' do
        @jirate.vcs.should_receive(:log).and_return("blah blah #{@ticket} assign chrphillips blah blah")
        @jirate.should_receive(:assign).with(@ticket, 'chrphillips').and_return(true)
        @jirate.shake
      end

      it 'should perform workflow action if ticket and a workflow action are present' do
        @jirate.vcs.should_receive(:log).and_return("#{@ticket} stop_qat")
        @jirate.should_receive(:stop_qat).with(@ticket).and_return(true)
        @jirate.shake
      end

      it 'should perform workflow action if ticket and a workflow action are present with blabber' do
        @jirate.vcs.should_receive(:log).and_return("blah blah #{@ticket} start_qat blah blah")
        @jirate.should_receive(:start_qat).with(@ticket).and_return(true)
        @jirate.shake
      end

      it 'should perform workflow action and assign to user if both are present' do
        @jirate.vcs.should_receive(:log).and_return("#{@ticket} start_qat assign chrphillips")
        @jirate.should_receive(:assign).with(@ticket, 'chrphillips').and_return(true)
        @jirate.should_receive(:start_qat).with(@ticket).and_return(true)
        @jirate.shake
      end

      it 'should perform workflow action and assign to user if both are present but reversed' do
        @jirate.vcs.should_receive(:log).and_return("#{@ticket} assign kmcclusky start_qat")
        @jirate.should_receive(:assign).with(@ticket, 'kmcclusky').and_return(true)
        @jirate.should_receive(:start_qat).with(@ticket).and_return(true)
        @jirate.shake
      end

      it 'should perform workflow action and assign to user if both are present with blabber' do
        @jirate.vcs.should_receive(:log).and_return("blah blah #{@ticket} start_qat blah blah assign chrphillips blah blah")
        @jirate.should_receive(:assign).with(@ticket, 'chrphillips').and_return(true)
        @jirate.should_receive(:start_qat).with(@ticket).and_return(true)
        @jirate.shake
      end

      it 'should perform workflow action and assign to user with blabber and order is reversed' do
        @jirate.vcs.should_receive(:log).and_return("blah blah assign kmcclusky blah blah #{@ticket} start_dev blah blah")
        @jirate.should_receive(:assign).with(@ticket, 'kmcclusky').and_return(true)
        @jirate.should_receive(:start_dev).with(@ticket).and_return(true)
        @jirate.shake
      end

      it "should iterate over multiple log entries" do
        log_array = []

        10.times do
          log_array << "blah blah assign kmcclusky blah blah #{@ticket} start_dev blah blah"
        end

        @jirate.vcs.should_receive(:log).and_return(log_array)
        @jirate.should_receive(:assign).with(@ticket, 'kmcclusky').exactly(10).times.and_return(true)
        @jirate.should_receive(:start_dev).with(@ticket).exactly(10).times.and_return(true)
        @jirate.shake
      end

      xit "should detect ticket values in lower case" do
        @jirate.vcs.should_receive(:log).and_return("#{@ticket.downcase} start_dev")
        @jirate.should_receive(:start_dev).with(@ticket).once.and_return(true)
        @jirate.shake
      end
    end
  end
end
