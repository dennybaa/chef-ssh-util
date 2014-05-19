# ssh-util cookbook

**ssh-util** cookbook provides various tools to manage openssh based systems.
The cookbook currently includes only **ssh_config** definition to manage system-wide and user-specific ssh_config files.

## Supported Platforms

Supposed to run on all  debian flavors.

## Usage

### Attributes

 * **node['ssh-util']['ssh_config']** system-wide ssh_config configuration which is a hash containing options and hosts keys which are also respectively hashes.
 * **node['ssh-util']['user_ssh_config'][UserName]** user-specific ssh_config configuration which is a hash containing options and hosts keys which are also respectively hashes.

**ssh_config** and **user_ssh_config** attributes are managed on the cookbook default precedence level by **ssh_config** definition. So if you might as well want to add your customizations it's suggested to use role or environment precedence levels.

### ssh_config definition

Provides the way to manage user and system-wide ssh_config files (*~/.ssh/config*, */etc/ssh/ssh_config* respectively). Typical invocation examples are provided bellow:

    ssh_config 'vagrant' do
      options(
        strict_host_key_checking: 'no',
        user_known_hosts_file: '/dev/null'
      )
      hosts(
        'github.com' => {
          user: 'git',
          identity_file: '/var/apps/github_deploy_key'
        }
      )
    end

    ssh_config 'vagrant' do
      options 'user_known_hosts_file', 'strict_host_key_checking'
      hosts(
        'github.com',
        'anotherhost.net'
      )
      action :remove
    end

Arguments:
 * **options** is a hash or an array of options to be added or removed from the configuration file. Use hash or array for `:append`, `:remove` actions respectively.
 * **hosts** is a hash of host specific options to be added to or an array of hosts to be removed from the configuration file. Use hash or array for `:append`, `:remove` actions respectively.
 * **action** can be `:append` or `:remove`. Default is `:append`.
 * **name** - the definition name corresponds to the user which configuration file is processed. If nothing is given the system-wide configuration file is processed.

**ssh_config** is a definition and it's implemented to create only a single configuration file. However it can be invoked many times from different cookbooks, the attributes will be properly merged or cleaned and the single copy of template will be altered.

### ssh-util::default

Include `ssh-util` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[ssh-util::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Denis Baryshev (<dennybaa@gmail.com>)
