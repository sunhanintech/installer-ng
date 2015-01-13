name             'scalr-server'
maintainer       'Thomas Orozco'
maintainer_email 'thomas@scalr.com'
license          'Apache License 2.0'
description      'Configures Scalr Server'
long_description 'Configures Scalr Server'
version          '7.9.3'

%w{ ubuntu centos redhat }.each do |os|
    supports os
end

depends 'apt', '~> 2.4.0'
depends 'yum', '~> 3.5.0'
depends 'iis', '~> 1.5.0'  # Required because 1.6.0 is broken, and php depends on iis
depends 'php', '~> 1.5.0'
depends 'python', '~> 1.4.0'
depends 'artifact', '~> 1.11.0'
depends 'database', '~> 2.3.1'
depends 'mysql', '~> 5.6.1'
depends 'apache2', '~> 3.0.0'
depends 'cron', '~> 1.4.0'

depends 'supervisor', '~> 0.4.12'
