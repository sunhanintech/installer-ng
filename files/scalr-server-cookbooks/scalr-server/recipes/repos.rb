case node[:platform_family]

when 'rhel', 'fedora'
  # Don't leave anything to chance: clear the metadata on all the repos.
  # This is useful in case someone happens to have a repo that we overwrite
  # (e.g. they had EPEL 6 and we register EPEL 7).
  execute 'yum --enablerepo=* clean metadata'

  # We need to use some extra repositories to pull specific packages
  # In order to not mess up the entire system, we use includepks to
  # ensure that only the packages we want are installed.

  # TODO - Use HTTPS or a file for gpgkey's!

  # EPEL uses a different key on 6 and 7.
  # Since we are using platform_version, might as well use it everywhere.
  rhel_version = node[:platform_version].to_i

  webtatic_pkgs         = ['libmysqlclient*', 'php*']
  epel_pkgs             = ['monit*', 'zeromq*', 'openpgm*']
  rpmforge_pkgs         = ['putty*']
  rpmforge_extras_pkgs  = []
  centos_base_pkgs      = []

  if rhel_version == 7
    epel_pkgs.concat        ['libmcrypt*']
    centos_base_pkgs.concat ['*rrdtool*', 'file*', 'libssh2*', 'libyaml*', 'libevent*', 'net-snmp*']
    webtatic_gpg_key = 'http://repo.webtatic.com/yum/RPM-GPG-KEY-webtatic-el7'
  else
    webtatic_pkgs.concat        ['libmcrypt*']
    rpmforge_extras_pkgs.concat ['*rrdtool*']
    webtatic_gpg_key = 'http://repo.webtatic.com/yum/RPM-GPG-KEY-webtatic-andy'
  end

  # Webtatic is where we can find up-to-date PHP packages.
  yum_repository 'webtatic' do
    description "Webtatic Repository #{rhel_version} - $basearch"
    mirrorlist  "http://mirror.webtatic.com/yum/el#{rhel_version}/$basearch/mirrorlist"
    gpgkey      webtatic_gpg_key
    includepkgs webtatic_pkgs.join(' ')
    action      :create
  end

  # We'll need EPEL for libyaml and monit. Webtatic has started depending on EPEL in RHEL 7, so
  # we also need to include those dependencies here.
  # Note that libyaml is in base on CentOS 7, and no longer in EPEL!
  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux'
    mirrorlist  "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-#{rhel_version}&arch=$basearch"
    gpgkey      "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{rhel_version}"
    includepkgs epel_pkgs.join(' ')
    action      :create
  end

  # We need putty, which we can find in repoforge.
  yum_repository 'rpmforge' do
    description "RHEL #{rhel_version} - RPMforge.net - base"
    mirrorlist  "http://apt.sw.be/redhat/el#{rhel_version}/en/mirrors-rpmforge"
    gpgkey      'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
    includepkgs rpmforge_pkgs.join(' ')
    action      :create
  end

  # We need an up-to-date rrdtool version that includes rrcached. We can find this in
  # repoforge-extras.
  yum_repository 'rpmforge-extras' do
    description "RHEL #{rhel_version} - RPMforge.net - extras"
    mirrorlist  "http://apt.sw.be/redhat/el#{rhel_version}/en/mirrors-rpmforge-extras"
    gpgkey      'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
    includepkgs rpmforge_extras_pkgs.join(' ')
    action      :create
  end

  # The Red Hat repositories are missing -devel packages that we need
  # $releasever?
  if node[:platform] == 'redhat'
    yum_repository 'centos-base' do
      description 'CentOS-$releasever - Base'
      mirrorlist  "http://mirrorlist.centos.org/?release=#{rhel_version}&arch=$basearch&repo=os"
      gpgkey      "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-#{rhel_version}"
      includepkgs centos_base_pkgs.join(' ')
      action      :create
    end
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
