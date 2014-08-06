case node[:platform_family]

when 'rhel', 'fedora'
  package 'yum-plugin-priorities'

  cookbook_file '/etc/yum/pluginconf.d/priorities.conf' do
    source "#{node[:platform_family]}-yum-priorities.conf"
  end

  # TODO - Use HTTPS or a file for gpgkey

  # EPEL uses a different key on 6 and 7.
  # Since we are using platform_version, might as well use it everywhere.
  rhel_version = node[:platform_version].to_i

  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux'
    mirrorlist "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-#{rhel_version}&arch=$basearch"
    gpgkey "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{rhel_version}"
    includepkgs 'libyaml* monit*'
    action :create
  end

  yum_repository 'rpmforge' do
    description "RHEL #{rhel_version} - RPMforge.net - base"
    mirrorlist "http://apt.sw.be/redhat/el#{rhel_version}/en/mirrors-rpmforge"
    gpgkey 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
    includepkgs 'putty'
    action :create
  end

  yum_repository 'rpmforge-extras' do
    description "RHEL #{rhel_version} - RPMforge.net - extras"
    mirrorlist "http://apt.sw.be/redhat/el#{rhel_version}/en/mirrors-rpmforge-extras"
    gpgkey 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
    includepkgs '*rrdtool*'
    action :create
  end

  yum_repository 'webtatic' do
    description 'Webtatic Repository EL6 - $basearch'
    mirrorlist "http://mirror.webtatic.com/yum/el#{rhel_version}/$basearch/mirrorlist"
    gpgkey 'http://repo.webtatic.com/yum/RPM-GPG-KEY-webtatic-andy'
    includepkgs 'libmysqlclient* libmcrypt* php*'
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
