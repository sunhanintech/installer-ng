name             'scalr-server'
maintainer       'Thomas Orozco'
maintainer_email 'thomas@scalr.com'
license          'Apache License 2.0'
description      'Configures Scalr Server'
long_description 'Configures Scalr Server'
version          '7.9.3'

%w{amazon centos debian fedora redhat ubuntu oracle}.each do |os|
    supports os
end

depends 'database', '~> 2.3.0'
depends 'supervisor', '~> 0.4.12'
