
# brave - feel free to convert to ruby svn bindings
module VcsDriver
  class Svn
    attr_accessor :conf

    def initialize(options={})
      self.conf = {
        'svn_user' => options[:user],
        'svn_pass' => options[:password],
        'svn_repo_master' => options[:url],
        'svn_repo_working_copy' => options[:working_copy]
      }

    end

    def log(limit=nil)
      if limit.nil?
        `svn log #{self.conf['svn_repo_master']}`
      else
        `svn log #{self.conf['svn_repo_master']} -l#{limit}`
      end
    end
  end
end