def whyrun_supported?
  true
end

def load_current_resource
  # @current_resource = Chef::Resource::SshUtilConfig.new(@new_resource.name)
  # puts '--------------------'
  # puts @new_resource.class
end

action :append do
end

action :remove do
end

# def config_owner
#   @config_owner ||= new_resource.user || 'root'
# end

# def config_gid
#   @config_owner ||= passwd_entry_for(config_owner).gid
# end

# def config_path
#   @config_path ||= begin
#     if new_resource.user
#       ::File.join(::File.expand_path("~#{config_owner}"), '.ssh', 'config') 
#     else
#       node['ssh-util']['config_path']
#       # global config is not supported so far
#       raise NotImplementedError, 'Global ssh_config is not implemented'
#     end
#   end
# end

# def passwd_entry_for(uid)
#   uid.is_a?(Fixnum) ? Etc.getpwuid(uid) : Etc.getpwnam(uid)
# end
