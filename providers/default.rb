require 'etc'

use_inline_resources

def whyrun_supported?
  true
end

action :run do
  @supported_order.each {|meth| self.send(meth) if new_resource.supports[meth]}
end

def initialize(new_resource, run_context)
  super
  @supported_order = [
    :manage_ssh_home,
    :authorized_keys,
    :ssh_config
  ]
end

def manage_ssh_home
  users = uniq_authkeys.keys
  users |= (node['ssh-util']['ssh_config_user'] || {}).keys
  users.each do |un|
    directory "~#{un}/.ssh" do
      path  lazy {::File.expand_path("~#{un}/.ssh")}
      group lazy {Etc.getpwnam(un).gid}
      owner un
      mode  00700
      if wait_for_user?(un)
        action :nothing
        subscribes :create, "user[#{un}]", :delayed
      end
    end
  end
end

def authorized_keys
  uniq_authkeys.each_pair do |un, keys|
    template "~#{un}/.ssh/authorized_keys" do
      path  lazy {::File.expand_path("~#{un}/.ssh/authorized_keys")}
      group lazy {Etc.getpwnam(un).gid}
      owner un
      mode  0644
      source 'authorized_keys.erb'
      variables(keys: keys)
      if wait_for_user?(un)
        action :nothing
        subscribes :create, "user[#{un}]", :delayed
      end
    end
  end
end

def ssh_config
  options = (node['ssh-util']['ssh_config'] || {}).to_hash
  global = options.delete('*')
  template node['ssh-util']['ssh_config_path'] do
    owner 'root'
    group 'root'
    mode  0644
    source 'ssh_config.erb'
    variables(options: global, hosts: options)
    not_if {global.empty? && options.empty?}
  end

  (node['ssh-util']['ssh_config_user'] || {}).each do |un, opts|
    options = opts.to_hash
    global = options.delete('*') || {}
    template "~#{un}/.ssh/config" do
      path  lazy {::File.expand_path("~#{un}/.ssh/authorized_keys")}
      group lazy {Etc.getpwnam(un).gid}
      owner un
      mode  0600
      source 'ssh_config.erb'
      variables(options: global, hosts: options)
      if wait_for_user?(un)
        action :nothing
        subscribes :create, "user[#{un}]", :delayed
      end
    end
  end
end

def uniq_authkeys
  @uniq_authkeys = begin
    (node['ssh-util']['authorized_keys'] || {}).inject({}) do |memo, obj|
      un, keys = obj
      memo[un] = keys.map {|str| public_key_from(str)}.uniq.inject([]) do |list, key|
        many = keys.select {|str| public_key_from(str) == key}
        if many.size > 1
          Chef::Log.debug "#{new_resource} user #{un} has several authorized_keys: #{key}"
        end
        list << many.first
      end
      memo
    end
  end
end

# We make execution of our resources delayed in case the user doesn't exist.
# Because it might be created later in other cookbooks.
def wait_for_user?(username)
  @wait_for_user ||= begin
    ent = Etc.getpwnam(username) rescue nil
    ent.nil? ? true : false
  end
end

def public_key_from(str)
  self.class.public_key_from(str)
end

def self.public_key_from(str)
  str.gsub(/.*(ssh-[rd]sa [^\s]+).*/) {$1}
end