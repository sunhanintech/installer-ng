case node[:platform_family]

when 'rhel', 'fedora'
  package 'yum-plugin-priorities'

  cookbook_file '/etc/yum/pluginconf.d/priorities.conf' do
    source "#{node[:platform_family]}-yum-priorities.conf"
  end

  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux'
    mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
    gpgkey 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'  #TODO: Include those keys in my package and use a file:/// url. HTTP is unsafe here.
    includepkgs 'libyaml* libmcrypt* monit*'
    action :create
  end

  yum_repository 'rpmforge-extras' do
    description 'RHEL $releasever - RPMforge.net - extras'
    baseurl 'http://apt.sw.be/redhat/el6/en/$basearch/extras'
    mirrorlist 'http://apt.sw.be/redhat/el6/en/mirrors-rpmforge-extras'
    gpgkey 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
    enabled true
    includepkgs '*rrdtool*'
    priority '1'
    action :create
  end

  yum_repository 'remi' do
    description 'Remi RPM'
    mirrorlist 'http://rpms.famillecollet.com/enterprise/6/remi/mirror'
    gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
    includepkgs 'php-*'
    action :create
  end

  yum_repository 'remi-php55' do
    description 'Remi RPM PHP'
    mirrorlist 'http://rpms.famillecollet.com/enterprise/6/php55/mirror'
    gpgkey 'http://rpms.famillecollet.com/RPM-GPG-KEY-remi'
    includepkgs 'php-*'
    action :create
  end
  
when 'debian'  #TODO: Find out how we support Debian here?
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
