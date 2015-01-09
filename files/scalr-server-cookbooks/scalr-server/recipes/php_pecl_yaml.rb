case node[:platform_family]

when 'rhel'
  # libyaml used to be EPEL but not base, so a lot of CentOS cloud images
  # have libyaml installed without a repo (koji-override-0), but they don't
  # have libyaml. Some other folks simply enabled EPEL when building their images
  # so they got libyaml from there.
  #
  # To address this, we used to downgrade libyaml if there was an override version
  # installed (we'd grep for it), which would result in installing the one from EPEL.
  #
  # In turn, we could then install libyaml-devel (from EPEL) without a conflict (otherwise
  # you have two different versions for libyaml and libyaml-devel, and things get ugly).
  #
  # But! In October 2014, CentOS added libyaml to their base repo. Only, it's an older
  # version than the one EPEL used to have. Folks that have an override still have
  # something that works, but now this breaks for EPEL folks, because of grepping
  # for the override doesn't work.
  #
  # So, enough non-sense, we now use a transaction to make sure libyaml and libyaml-devel
  # are installed together, removing libyaml if it was there before.

  transaction_source = 'yum-libyaml-tx'
  transaction_file = "#{Chef::Config[:file_cache_path]}/#{transaction_source}"

  cookbook_file transaction_source do
    path  transaction_file
    mode  0700
  end

  execute "yum --assumeyes shell #{transaction_file}" do
    not_if "yum list installed libyaml-devel"
  end
when 'debian'
  package 'libyaml-dev'
end

php_pear 'yaml' do
  action :install
  version '1.1.1'
end

scalr_server_phpmod 'yaml'
