# ssh-util cookbook

**ssh-util** cookbook provides ssh-util resource which helps to manage:

 * Users ssh home directories (*~/.ssh*), namely creates them and sets permissions.
 * Users authorized_keys files.
 * Users and system-wide ssh_config files.

## Supported Platforms

Supposed to run on all  debian flavors.

## Usage

Important issue in **ssh-util** provider work is that that it allows you to create users separately in the later cookbooks' recipes. In this case
it will try to subscribe to **'user[#{username}]'** resources. So execution might fail fail if the missing user is not created by the user resource in the given notation.

### Attributes

 * **node['ssh-util']['ssh_config']** system-wide ssh_config configuration hash.
 * **node['ssh-util']['ssh_config_user'][UserName]** user-specific ssh_config configuration hash.
 * **node['ssh-util']['authorized_keys'][UserName]** user's authorized keys array

All the above attributes can be managed through roles, environments and directly. However for more handy usage this cookbook provides definition helpers **ssh_authorized_keys** and **ssh_config**.

### Definitions

All definitions operate on *recipe default attribute level* and they are supposed to be invoked multiple times from different cookbooks and recipes. The main job only to setup attributes in predictable manner, all the job itself is carried by the **ssh-util** resource provider.

#### ssh_authorized_keys

The definition supports two actions **:append** and **:remove**. Usage example:

    ssh_authorized_keys do
        action :append
        user 'root'
        keys 'ssh-rsa SomeLongKey1'
    end

    ssh_authorized_keys do
        action :append
        user 'root'
        keys 'ssh-rsa SomeLongKey2'
    end

    ssh_authorized_keys do
        action :remove
        user 'root'
        keys 'ssh-rsa SomeLongKey1'
    end
    
The above code works in the predictable manner and after the chefrun completes you will find only the *SomeLongKey2* in the root's authorized_keys file.

#### ssh_config

Supports only **:append** action. It can be used to create and populate *~/.ssh/config* and */etc/ssh/ssh_config* configuration files. Provides the way to setup user and system-wide ssh_config attributes. Usage example:

    ssh_config do
        user 'vagrant'
        options({
            '*' => {
                strict_host_key_checking: 'no',
                user_known_hosts_file: '/dev/null'
            },
            'github.com' => {
                user: 'git',
                identity_file: '/var/apps/github_deploy_key'
            }
        })
    end
    
Special host __*__ sets the global options which go first in the configuration file.


## Resource configuration

To completely disable one of the following features *manage_ssh_home*, *authorized_keys*, *ssh_config* you might wnat to override node['ssh-util']['default_supports'] attribute.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Denis Baryshev (<dennybaa@gmail.com>)