name             'scalr-server'
maintainer       'Thomas Orozco'
maintainer_email 'thomas@scalr.com'
license          'Apache License 2.0'
description      'Installs/Configures Scalr Core'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '7.12.0'

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
