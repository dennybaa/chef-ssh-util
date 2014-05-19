default['ssh-util']['ssh_config_path'] = '/etc/ssh/ssh_config'
default['ssh-util']['config_template'] = 'ssh_config.erb'
default['ssh-util']['config_cookbook'] = 'ssh-util'
# default['ssh-util']['user_ssh_config']  =

# platform defaults for system-wide settings
case node['platform_family']
when 'debian'
  default['ssh-util']['ssh_config']['options']['send_env'] = 'LANG LC_*'
  default['ssh-util']['ssh_config']['options']['hash_known_hosts'] = 'yes'
  default['ssh-util']['ssh_config']['options']['gss_api_authentication'] = 'yes'
  default['ssh-util']['ssh_config']['options']['gss_api_delegate_credentials'] = 'no'
end