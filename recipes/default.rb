include_recipe 'apt'

case node[:platform]
when 'redhat', 'centos'
  include_recipe 'yum'

  yum_repository 'epel' do
    description 'Extra Packages for Enterprise Linux'
    mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
    gpgkey 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
    action :create
  end
end

include_recipe 'scalr-core::php'
