require 'etc'

module SSHUtil
  module Config

    # Dynamically create a single copy of the configuration template
    def ssh_template_resource
      tpl_name = params[:user] ? "ssh_config for #{params[:user]}" : "ssh_config system-wide"
      @run_context.resource_collection.lookup("template[#{tpl_name}")
    rescue Chef::Exceptions::ResourceNotFound
      directory "ssh_config parent directory for #{tpl_name}" do
        path  lazy {
          if params[:user]
            ::File.expand_path("~#{params[:user]}/.ssh")
          else
            ::File.dirname(node['ssh-util']['ssh_config'])
          end
        }
        owner params[:owner]
        group lazy {SSHUtil::Config.passwd_ent(params[:owner]).gid}
        mode  params[:user] ? 00700 : 00755
        recursive true
        action :create
      end
      template tpl_name do
        path  lazy {
          if params[:user]
            ::File.expand_path("~#{params[:user]}/.ssh/config")
          else
            node['ssh-util']['ssh_config']
          end
        }
        owner params[:owner]
        group lazy {SSHUtil::Config.passwd_ent(params[:owner]).gid}
        mode  params[:user] ? 00600 : 00644
        source   node['ssh-util']['config_template']
        cookbook node['ssh-util']['config_cookbook']
        variables lazy {
          base = (params[:user] ? node['ssh-util']['user_ssh_config'][params[:user]] :
            node['ssh-util']['ssh_config'])
          {options: base[:options], hosts: base[:hosts]}
        }
      end
    end

    def self.passwd_ent(uid)
      uid.is_a?(Fixnum) ? Etc.getpwuid(uid) : Etc.getpwnam(uid)
    end

  end
end
