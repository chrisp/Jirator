require 'yaml'
require 'jira4r'
require File.expand_path(File.join(File.dirname(__FILE__), 'vcs.rb'))

class Jirate
  attr_accessor :conf, :vcs, :jira

  def initialize
    self.conf = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'jirate.conf')))
    self.vcs = Vcs.new({
      :driver => conf['vcs_driver'],
      :user => conf['vcs_user'],
      :password => conf['vcs_password'],
      :working_copy => conf['working_copy'],
      :url => conf['repository']
    })

    self.jira = Jira4R::JiraTool.new(2, conf['jira_url'])
    jira.login(conf['jira_user'], conf['jira_password'])
    puts jira.getProject(conf['jira_project']).inspect
  end

  def shake
    log_contents = vcs.log(1)

    cmd = log_contents.match(/assign #{conf['jira_project']}-(\w+) (\w+)/).to_s
    cmd = log_contents.match(/(fix|start|take) #{conf['jira_project']}-(\w+)/).to_s if (cmd.nil? || cmd.empty?)

    results = `geera #{cmd}`
    puts results
  end
end
