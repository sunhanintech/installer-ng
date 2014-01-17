case node[:platform]

when 'redhat', 'centos'
  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux'
    mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
    gpgkey 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
    action :create
  end

  yum_repository 'remi' do
    description 'Remi RPM'
    mirrorlist 'http://rpms.famillecollet.com/enterprise/6/remi/mirror'
    gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
    action :create
  end

  yum_repository 'remi-php55' do
    description 'Remi RPM PHP'
    mirrorlist 'http://rpms.famillecollet.com/enterprise/6/php55/mirror'
    gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
    action :create
  end
  
when 'ubuntu'  #TODO: Find out how we support Debian here?
  # Ondrej PPA
  apt_repository 'ondrej' do
    uri          'http://ppa.launchpad.net/ondrej/php5/ubuntu'
    distribution node['lsb']['codename']
    components   ['main']
    keyserver    'keyserver.ubuntu.com'
    key          'E5267A6C'
    deb_src      true
  end

  apt_repository 'multiverse' do
    uri 'http://archive.ubuntu.com/ubuntu/'
    distribution node['lsb']['codename']
    components   ['multiverse']
    keyserver    'keyserver.ubuntu.com'
  end
end
