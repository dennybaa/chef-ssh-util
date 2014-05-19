require 'etc'

module SSHUtil
  module Config

    # Dynamically create a single copy of the configuration template
    def ssh_template_resource
      opts = ssh_prepare_opts
      @run_context.resource_collection.lookup("template[#{opts[:config_path]}]")
    rescue Chef::Exceptions::ResourceNotFound
      directory ::File.dirname(opts[:config_path]) do
        owner opts[:owner]
        group opts[:gid]
        mode  opts[:config_global] ? 00755 : 00700
        recursive true
        action :create
      end
      template opts[:config_path] do
        owner opts[:owner]
        group opts[:gid]
        mode  opts[:config_global] ? 00644 : 00600
        source   node['ssh-util']['config_template']
        cookbook node['ssh-util']['config_cookbook']
        variables lazy {
          base = (opts[:config_global] ? node['ssh-util']['ssh_config'] :
            node['ssh-util']['user_ssh_config'][opts[:user]])
          {options: base[:options], hosts: base[:hosts]}
        }
      end
    end

    # Prepare ssh config opts hash
    def ssh_prepare_opts
      @ssh_config_opts ||= begin
        m = Mash.new
        m[:user]   = params[:name]
        m[:owner]  = m[:user] || 'root'
        m[:gid]    = passwd_entry_for(m[:owner]).gid
        m[:config_global] = m[:user].to_s.empty? ? true : false
        m[:config_path]   = m[:config_global] ? node['ssh-util']['ssh_config_path'] :
            ::File.join(::File.expand_path("~#{m[:user]}"), '.ssh', 'config')
        m
      end
    end

    def passwd_entry_for(uid)
      uid.is_a?(Fixnum) ? Etc.getpwuid(uid) : Etc.getpwnam(uid)
    end

  end
end
