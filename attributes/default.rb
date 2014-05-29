default['ssh-util']['ssh_config_template'] = 'ssh_config.erb'
default['ssh-util']['ssh_config_cookbook'] = 'ssh-util'

# All platform defaults of system-wide settings which are
# passed to openssh if it's included.
default['ssh-util']['ssh_config'] = {
  send_env: 'LANG LC_*',
  hash_known_hosts: 'yes',
  gssapi_authentication: 'yes',
  gssapi_delegate_credentials: 'no'
}

default['ssh-util']['default_supports'] = {
  manage_ssh_home: true,
  authorized_keys: true,
  ssh_config_user: true
}

default['ssh-util']['authorized_keys'] = {}
default['ssh-util']['ssh_config_user'] = {}