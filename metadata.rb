name             'scalr-core'
maintainer       'Thomas Orozco'
maintainer_email 'thomas@scalr.com'
license          'All rights reserved'
description      'Installs/Configures Scalr Core'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

%w{ debian ubuntu centos redhat }.each do |os|
    supports os
end


depends 'iis', '~> 1.5.0'  # Required because 1.6.0 is broken, and php depends on it!
depends 'php', '~> 1.3.0'
depends 'apt', '~> 2.0.0'
