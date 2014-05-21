default['ssh-util']['ssh_config_path'] = '/etc/ssh/ssh_config'
default['ssh-util']['ssh_config_template'] = 'ssh_config.erb'
default['ssh-util']['ssh_config_cookbook'] = 'ssh-util'

# platform defaults for system-wide settings
case node['platform_family']
when 'debian'
  default['ssh-util']['ssh_config'] = {
    '*' => {
      send_env: 'LANG LC_*',
      hash_known_hosts: 'yes',
      gss_api_authentication: 'yes',
      gss_api_delegate_credentials: 'no'
    }
  }
end

default['ssh-util']['default_supports'] = {
  manage_ssh_home: true,
  authorized_keys: true,
  ssh_config: true
}