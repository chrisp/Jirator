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

    cmd = log_contents.match(/assign #{conf['jira_project']}-(\w+) (\w+)/).to_s
    cmd = log_contents.match(/(fix|start|take) #{conf['jira_project']}-(\w+)/).to_s if (cmd.nil? || cmd.empty?)
  end

  JIRA_CONF['actions'].keys.each do |action|
    module_eval(%Q{
      def #{action}(ticket, assignee=conf['jira_user'])
        jira.progressWorkflowAction(ticket, conf['actions']['#{action}'], passthrough_attributes)
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
