# ssh-util cookbook

**ssh-util** cookbook provides ssh-util resource which helps to manage:

 * Users ssh home directories (*~/.ssh*), namely creates them and sets permissions.
 * Users authorized_keys files.
 * Users ssh_config files.

## Supported Platforms

Supposed to run any platform.

## Usage

_**Important idea**_ is that that **ssh-util** provider operation allows you to create users separately from this cookbook. This basically means that you can invoke **'user[#{username}]'** in any of your cookbooks' recipes. The **ssh-util** provider will try to subscribe with the *delayed* execution for a user resource. Mind that operation might fail in case you create a user using the different resource name.

### Attributes

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

Supports only **:append** action. Provides a way to populate *ssh_config_user* attributes which effect on user *~/.ssh/config* configuration files generation. Usage example:

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

To completely disable one of the following features *manage_ssh_home*, *authorized_keys*, *ssh_config_user* you might wnat to override node['ssh-util']['default_supports'] attribute.

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Denis Baryshev (<dennybaa@gmail.com>)