require 'etc'

module SSHUtil
  module Config

    # Dynamically create a single copy of the configuration template
    def ssh_template_resource
      opts = ssh_config_opts
      @run_context.resource_collection.lookup("template[#{opts[:config_path]}]")
    rescue Chef::Exceptions::ResourceNotFound
      directory ::File.dirname(opts[:config_path]) do
        owner opts[:owner]
        group opts[:gid]
        mode(opts[:config_global] ? 00755 : 00700)
        recursive true
        action :create
      end
      template opts[:config_path] do
        owner opts[:owner]
        group opts[:gid]
        mode(opts[:config_global] ? 00644 : 00600)
        source   node['ssh-util']['config_template']
        cookbook node['ssh-util']['config_cookbook']
        unless opts[:config_global]
          variables lazy {{
            options: node['ssh-util'][:config_users][owner][:options],
            hosts:   node['ssh-util'][:config_users][owner][:hosts]
          }}
        end
      end
    end

    # Prepare ssh config opts hash
    def ssh_config_opts
      @ssh_config_opts ||= begin
        m = Mash.new
        m[:owner]  = params[:user] || 'root'
        m[:gid]    = passwd_entry_for(m[:owner]).gid
        m[:config_global] = params[:user].nil? ? true : false
        m[:config_path]   = begin
          unless m[:global_config]
            ::File.join(::File.expand_path("~#{m[:owner]}"), '.ssh', 'config')
          else
            Chef::Log.error "ssh_config[#{params[:name]}] You must use :user attribute"
            raise NotImplementedError, 'Global ssh_config is not implemented'
            node['ssh-util']['ssh_config']
          end
        end
        m
      end

    end

    def passwd_entry_for(uid)
      uid.is_a?(Fixnum) ? Etc.getpwuid(uid) : Etc.getpwnam(uid)
    end

  end
end
