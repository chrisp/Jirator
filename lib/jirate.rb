require 'yaml'
require 'rubygems'
require 'jira4r'
require File.expand_path(File.join(File.dirname(__FILE__), 'vcs.rb'))

JIRA_CONF = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'jirate.yml')))

class Jirate
  attr_accessor :conf, :vcs, :jira

  def initialize
    self.conf = JIRA_CONF
    self.vcs = Vcs.new({
      :driver => conf['vcs_driver'],
      :user => conf['vcs_user'],
      :password => conf['vcs_password'],
      :working_copy => conf['working_copy'],
      :url => conf['repository']
    })

    self.jira = Jira4R::JiraTool.new(2, conf['jira_url'])
    jira.login(conf['jira_user'], conf['jira_password'])
  end

  def shake
    log_contents = vcs.log(1)

    ticket = log_contents.match(/#{conf['jira_project']}-(\w+) /).to_s.strip
    assignee = log_contents.match(/assign (\w+)/).to_s.gsub('assign ', '').strip
    action = log_contents.match(/#{conf['actions'].keys.join('|')}/).to_s.strip

    begin
      assign(ticket, assignee) unless ticket.nil? || assignee.nil? || assignee.empty?
      send(action, ticket) unless ticket.nil? || action.nil? || action.empty?
    rescue Exception => e
      # A logger should capture this
      puts e.message
      puts e.backtrace.inspect
    end
  end

  JIRA_CONF['actions'].keys.each do |action|
    module_eval(%Q{
      def #{action}(ticket, assignee=conf['jira_user'])
        if jira.getAvailableActions(ticket).map {|a| a.id.to_i}.include?(conf['actions']['#{action}'])
          jira.progressWorkflowAction(ticket, conf['actions']['#{action}'], passthrough_attributes)
        else
          # A logger should capture this
          puts "#{action} is not available"
        end
      end
    })
  end

  def assign(ticket, assignee)
    jira.updateIssue(ticket, [Jira4R::V2::RemoteFieldValue.new('assignee', assignee)])
  end

  def passthrough_attributes(assignee=nil)
    [
      Jira4R::V2::RemoteFieldValue.new('assignee', assignee.nil? ? conf['jira_user'] : assignee),
      Jira4R::V2::RemoteFieldValue.new('description', 'description'),
      Jira4R::V2::RemoteFieldValue.new('priority', 'priority'),
    ]
  end
end
