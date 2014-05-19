name             'ssh-util'
maintainer       'Twiket LTD'
maintainer_email 'denz@twiket.com'
license          'Apache 2.0'
description      'Installs/Configures ssh-util'
long_description 'Installs/Configures ssh-util'
version          '0.1.1'

%w(debian ubuntu).each {|os| supports os}
