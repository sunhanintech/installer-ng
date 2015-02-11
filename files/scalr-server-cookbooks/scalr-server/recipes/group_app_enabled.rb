require 'digest'
Chef::Resource::File.send(:include, Scalr::ConfigHelper)


# user

user 'scalr_user' do
  username  node[:scalr_server][:app][:user]
  home      "#{node[:scalr_server][:install_root]}/embedded/scalr"
  shell     '/bin/sh'  # TODO - Needed?
  system    true
end


# Scalr system directories

directory "#{run_dir_for(node, 'scalr')}/cache" do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0770
  recursive true
end

link "#{scalr_bundle_path node}/app/cache" do
  to "#{run_dir_for(node, 'scalr')}/cache"
end

directory "#{scalr_bundle_path node}/app/etc" do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
end

directory etc_dir_for(node, 'scalr') do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
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
  recursive true
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

directory "#{run_dir_for node, 'php'}/sessions" do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0775
  recursive true
end

directory log_dir_for(node, 'php') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end


# PHP configuration

directory etc_dir_for(node, 'php') do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
end

# TODO - Reload services on change here
template 'php_ini' do
  path      "#{etc_dir_for node, 'php'}/php.ini"
  source    'app/php.ini.erb'
  owner     'root'
  group     'root'
  mode      0644
  helpers(Scalr::PathHelper)
end


# Load database structure and data

mysql_database 'load scalr database structure' do
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/structure.sql").read }
  not_if          { mysql_has_table?(mysql_scalr_params(node), node[:scalr_server][:mysql][:scalr_dbname], 'upgrades') }
  action          :query
end

mysql_database 'load scalr database data' do
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/data.sql").read }
  not_if          { mysql_has_rows?(mysql_scalr_params(node), node[:scalr_server][:mysql][:scalr_dbname], 'upgrades') }
  action          :query
end

mysql_database 'load analytics database structure' do
  connection      mysql_analytics_params(node)
  database_name   node[:scalr_server][:mysql][:analytics_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/analytics_structure.sql").read }
  not_if          { mysql_has_table?(mysql_analytics_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
  action          :query
end

mysql_database 'load analytics database data' do
  connection      mysql_analytics_params(node)
  database_name   node[:scalr_server][:mysql][:analytics_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/analytics_data.sql").read }
  not_if          { mysql_has_rows?(mysql_analytics_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
  action          :query
end

execute 'Upgrade Scalr Database' do
  # NOTE: the app user needs to be created first, but the app recipe *is* supposed to run first.
  user    node[:scalr_server][:app][:user]
  group   node[:scalr_server][:app][:user]
  returns 0
  command "#{node[:scalr_server][:install_root]}/embedded/bin/php upgrade.php"
  cwd     "#{scalr_bundle_path node}/app/bin"
end


# Run validation - it never hurts.

['root', node[:scalr_server][:app][:user]].each do |usr|
  execute "validate-as-#{usr}" do
    user  usr
    command "#{node[:scalr_server][:install_root]}/embedded/bin/php -c #{etc_dir_for node, 'php'} testenvironment.php"
    returns 0
    cwd "#{scalr_bundle_path node}/app/www"
  end
end



# Initialize Scalr administrator

default_username = 'admin'
hashed_default_password = Digest::SHA2.new(256).update('admin').hexdigest

new_username = node[:scalr_server][:app][:admin_user]
hashed_new_password = Digest::SHA2.new(256).update(node[:scalr_server][:app][:admin_password]).hexdigest

admin_id = 1

# The queries below are idempotent and only change the password in case it was set to the default.
mysql_database 'set admin username' do
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET email='#{new_username}' WHERE id=#{admin_id} AND email='#{default_username}'"
  action          :query
end

mysql_database 'set admin password' do
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET password='#{hashed_new_password}' WHERE id=#{admin_id} AND password='#{hashed_default_password}'"
  action          :query
end
