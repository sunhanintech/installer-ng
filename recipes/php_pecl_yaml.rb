case node[:platform_family]

when 'rhel'
  # When cloud-init is installed, RHEL has libyaml installed,
  # but it's tagged release: 1.1.el6. This prevents us from installing
  # libyaml-devel from epel, which is tagged release: 1.el6 and depends
  # on libyaml itself.
  #
  # Unfortunately, Red Hat does not ship libyaml-devel, so we have to
  # uninstall libyaml to then be able to install libyaml-devel.
  #
  # libyaml isn't installed through a repo, so we just need to check
  # whether there's an override, and downgrade if there is.

  execute 'yum --assumeyes downgrade libyaml' do
    only_if 'yum info libyaml | grep koji-override-0'
  end

  package 'libyaml-devel'
when 'debian'
  package 'libyaml-dev'
end

php_pear 'yaml' do
  action :install
  version '1.1.1'
end

scalr_core_phpmod 'yaml'
