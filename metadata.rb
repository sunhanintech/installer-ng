name             'scalr-core'
maintainer       'Thomas Orozco'
maintainer_email 'thomas@scalr.com'
license          'All rights reserved'
description      'Installs/Configures Scalr Core'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

%w{ ubuntu centos redhat }.each do |os|
    supports os
end


depends 'iis', '~> 1.5.0'  # Required because 1.6.0 is broken, and php depends on it!
depends 'php', '~> 1.3.0'
depends 'apt', '~> 2.3.0'
depends 'yum', '~> 3.0.0'
depends 'artifact', '~> 1.11.0'
depends 'database', '~> 1.4.0'
depends 'mysql', '~> 3.0.0'
depends 'apache2', '~> 1.8.14'
