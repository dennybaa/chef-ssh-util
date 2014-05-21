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
    pwent = Etc.getpwnam(un)
    directory "#{pwent.dir}/.ssh" do
      owner un
      group pwent.gid
      mode  00700
    end
  end
end

def authorized_keys
  uniq_authkeys.each_pair do |un, keys|
    pwent = Etc.getpwnam(un)
    template "#{pwent.dir}/.ssh/authorized_keys" do
      owner un
      group pwent.gid
      mode  0644
      source 'authorized_keys.erb'
      variables(keys: keys)
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
    pwent = Etc.getpwnam(un)
    options = opts.to_hash
    global = options.delete('*')
    template "#{pwent.dir}/.ssh/config" do
      owner un
      group pwent.gid
      mode  0600
      source 'ssh_config.erb'
      variables(options: global, hosts: options)
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

def public_key_from(str)
  self.class.public_key_from(str)
end

def self.public_key_from(str)
  str.gsub(/.*(ssh-[rd]sa [^\s]+).*/) {$1}
end
