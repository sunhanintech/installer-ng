Chef::Resource::File.send(:include, Scalr::ConfigHelper)

# Scalr system directories

directory run_dir_for(node, 'scalr') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0770
end

directory "#{run_dir_for(node, 'scalr')}/cache" do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0770
end

link "#{scalr_bundle_path node}/app/cache" do
  to "#{run_dir_for(node, 'scalr')}/cache"
end

directory "#{scalr_bundle_path node}/app/etc" do
  owner     'root'
  group     'root'
  mode      0755
end

directory etc_dir_for(node, 'scalr') do
  owner     'root'
  group     'root'
  mode      0755
end

# Scalr config files, and links.

file 'scalr_config' do
  path    "#{etc_dir_for node, 'scalr'}/config.yml"
  content dump_scalr_configuration(node)
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640
end

file 'scalr_cryptokey' do
  path    "#{etc_dir_for node, 'scalr'}/.cryptokey"
  content node[:scalr_server][:app][:secret_key]
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640
end

file 'scalr_id' do
  path    "#{etc_dir_for node, 'scalr'}/id"
  content node[:scalr_server][:app][:id]
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640
end

%w(config.yml .cryptokey id).each do |f|
  link "#{scalr_bundle_path node}/app/etc/#{f}" do
    to "#{etc_dir_for node, 'scalr'}/#{f}"
  end
end


# Helper to reload daemons when the code is updated

directory run_dir_for(node, 'app') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
end

file 'scalr_code' do
  path    "#{run_dir_for node, 'app'}/code"
  content node[:scalr_server][:manifest][:full_revision]
  owner   node[:scalr_server][:app][:user]
  group   node[:scalr_server][:app][:user]
  mode    0644
end


# TODO - Might as well be in a enable_web recipe, but... not a big deal for now.
# TODO - Session GC cron when web is enabled!!
# PHP sessions and error log dirs

directory run_dir_for(node, 'php') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
end

directory "#{run_dir_for node, 'php'}/sessions" do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
end

directory log_dir_for(node, 'php') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end


# PHP configuration

directory etc_dir_for(node, 'php') do
  owner     'root'
  group     'root'
  mode      0755
end

template 'php_ini' do
  path      "#{etc_dir_for node, 'php'}/php.ini"
  source    'app/php.ini.erb'
  owner     'root'
  group     'root'
  mode      0644
  helpers do
    include Scalr::PathHelper
    include Scalr::ServiceHelper
  end
end


# Ldap configuration
directory etc_dir_for(node, 'openldap') do
  owner     'root'
  group     'root'
  mode      0755
end

template 'ldap_conf' do
  path      "#{etc_dir_for node, 'openldap'}/ldap.conf"
  source    'app/ldap.conf.erb'
  owner     'root'
  group     'root'
  mode      0644
end


# Email configuration

directory etc_dir_for(node, 'ssmtp') do
  owner   'root'
  group   'root'
  mode    0755
end

template 'ssmtp_conf' do
  path    "#{etc_dir_for node, 'ssmtp'}/ssmtp.conf"
  source  'app/ssmtp.conf.erb'
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640  # Restrictive because the contents of the we send
  helpers do
    include Scalr::PathHelper
    include Scalr::ServiceHelper
  end
end

directory log_dir_for(node, 'ssmtp') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'unsent-mail') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0750  # Restrictive because the contents of the emails may be confidential
end

template 'unsent_mail_readme' do
  path    "#{log_dir_for node, 'unsent-mail'}/README"
  source  'app/UnsentMail_README.erb'
  owner   'root'
  group   'root'
  mode    0644
  helpers do
    include Scalr::PathHelper
  end
  action ssmtp_use?(node) ? :delete : :create
end

directory bin_dir_for(node, 'mail') do
  owner   'root'
  group   'root'
  mode    0755
end

template 'log_mail' do
  path    "#{bin_dir_for node, 'mail'}/log_mail"
  source  'app/log_mail.erb'
  owner   'root'
  group   'root'
  mode    0755
  helpers do
    include Scalr::PathHelper
  end
  action ssmtp_use?(node) ? :delete : :create
end

link "#{bin_dir_for node, 'mail'}/ssmtp" do
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0755
  to      ssmtp_use?(node) ? "#{node[:scalr_server][:install_root]}/embedded/sbin/ssmtp" : "#{bin_dir_for node, 'mail'}/log_mail"
end
