Chef::Resource::File.send(:include, Scalr::ConfigHelper)

# Scalr system directories

directory run_dir_for(node, 'scalr') do
  description "Create directory (" + run_dir_for(node, 'scalr') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0770
end

directory "#{run_dir_for(node, 'scalr')}/cache" do
  description "Create directory (" + "#{run_dir_for(node, 'scalr')}/cache" + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0770
end

link "#{scalr_bundle_path node}/app/cache" do
  description "Create link (" + "#{scalr_bundle_path node}/app/cache" + " to " + "#{run_dir_for(node, 'scalr')}/cache" + ")"
  to "#{run_dir_for(node, 'scalr')}/cache"
end

directory "#{scalr_bundle_path node}/app/etc" do
  description "Create directory (" + "#{scalr_bundle_path node}/app/etc" + ")"
  owner     'root'
  group     'root'
  mode      0755
end

directory etc_dir_for(node, 'scalr') do
  description "Create directory (" + etc_dir_for(node, 'scalr') + ")"
  owner     'root'
  group     'root'
  mode      0755
end

# Scalr config files, and links.

file 'scalr_config' do
  description "Create Scalr config file (" + "#{etc_dir_for node, 'scalr'}/config.yml" + ")"
  path    "#{etc_dir_for node, 'scalr'}/config.yml"
  content dump_scalr_configuration(node)
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640
end

file 'scalr_cryptokey' do
  description "Create cryptokey file (" + "#{etc_dir_for node, 'scalr'}/.cryptokey" + ")"
  path    "#{etc_dir_for node, 'scalr'}/.cryptokey"
  content node[:scalr_server][:app][:secret_key]
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640
end

file 'scalr_id' do
  description "Create scalr_id file (" + "#{etc_dir_for node, 'scalr'}/id" + ")"
  path    "#{etc_dir_for node, 'scalr'}/id"
  content node[:scalr_server][:app][:id]
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0640
end

%w(config.yml .cryptokey id).each do |f|
  link "#{scalr_bundle_path node}/app/etc/#{f}" do
    description "Create link (" + "#{scalr_bundle_path node}/app/etc/#{f}" + " to " + "#{etc_dir_for node, 'scalr'}/#{f}" + ")"
    to "#{etc_dir_for node, 'scalr'}/#{f}"
  end
end


# Helper to reload daemons when the code is updated

directory run_dir_for(node, 'app') do
  description "Create directory (" + run_dir_for(node, 'app') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
end

file 'scalr_code' do
  description "Create Scalr version file (" + "#{run_dir_for node, 'app'}/code" + ")"
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
  description "Create directory (" + run_dir_for(node, 'php') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
end

directory "#{run_dir_for node, 'php'}/sessions" do
  description "Create directory (" + "#{run_dir_for node, 'php'}/sessions" + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
end

directory log_dir_for(node, 'php') do
  description "Create directory (" + log_dir_for(node, 'php') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end


# PHP configuration

directory etc_dir_for(node, 'php') do
  description "Create directory (" + etc_dir_for(node, 'php') + ")"
  owner     'root'
  group     'root'
  mode      0755
end

template 'php_ini' do
  description "Create PHP configuration file (" + "#{etc_dir_for node, 'php'}/php.ini" + ")"
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
  description "Create directory (" + etc_dir_for(node, 'openldap') + ")"
  owner     'root'
  group     'root'
  mode      0755
end

template 'ldap_conf' do
  description "Create LDAP configuration file (" + "#{etc_dir_for node, 'openldap'}/ldap.conf" + ")"
  path      "#{etc_dir_for node, 'openldap'}/ldap.conf"
  source    'app/ldap.conf.erb'
  owner     'root'
  group     'root'
  mode      0644
end


# Email configuration

directory etc_dir_for(node, 'ssmtp') do
  description "Create directory (" + etc_dir_for(node, 'ssmtp') + ")"
  owner   'root'
  group   'root'
  mode    0755
end

template 'ssmtp_conf' do
  description "Create SSMTP configuration file (" + "#{etc_dir_for node, 'ssmtp'}/ssmtp.conf" + ")"
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
  description "Create directory (" + log_dir_for(node, 'ssmtp') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'unsent-mail') do
  description "Create directory (" + log_dir_for(node, 'unsent-mail') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0750  # Restrictive because the contents of the emails may be confidential
end

template 'unsent_mail_readme' do
  description "Create README for unsent mail (" + "#{log_dir_for node, 'unsent-mail'}/README" + ")"
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
  description "Create directory (" + bin_dir_for(node, 'mail') + ")"
  owner   'root'
  group   'root'
  mode    0755
end

template 'log_mail' do
  description "Create file that logs outgoing mail (" + "#{bin_dir_for node, 'mail'}/log_mail" + ")"
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

link_to = ssmtp_use?(node) ? "#{node[:scalr_server][:install_root]}/embedded/sbin/ssmtp" : "#{bin_dir_for node, 'mail'}/log_mail"
link "#{bin_dir_for node, 'mail'}/ssmtp" do
  description "Create link (" + "#{bin_dir_for node, 'mail'}/ssmtp" + " to " + link_to + ")"
  owner   'root'
  group   node[:scalr_server][:app][:user]
  mode    0755
  to      link_to
end
