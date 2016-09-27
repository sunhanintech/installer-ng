require 'digest'


# Load database structure and data

mysql_database 'load scalr database structure' do
  description     "Create main Scalr database structure"
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/structure.sql").read }
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
  not_if          { mysql_has_table?(mysql_scalr_params(node), node[:scalr_server][:mysql][:scalr_dbname], 'upgrades') }
  action          :query
end

mysql_database 'load scalr database data' do
  description     "Import main Scalr database data"
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/data.sql").read }
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
  not_if          { mysql_has_rows?(mysql_scalr_params(node), node[:scalr_server][:mysql][:scalr_dbname], 'upgrades') }
  action          :query
end

mysql_database 'load analytics database structure' do
  description     "Create Scalr analytics database structure"
  connection      mysql_analytics_params(node)
  database_name   node[:scalr_server][:mysql][:analytics_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/analytics_structure.sql").read }
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
  not_if          { mysql_has_table?(mysql_analytics_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
  action          :query
end

mysql_database 'load analytics database data' do
  description     "Import Scalr analytics database data"
  connection      mysql_analytics_params(node)
  database_name   node[:scalr_server][:mysql][:analytics_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/analytics_data.sql").read }
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
  not_if          { mysql_has_rows?(mysql_analytics_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
  action          :query
end

execute 'Upgrade Scalr Database' do
  description     "Upgrade Scalr Database (this might take a long time!)"
  # NOTE: the app user needs to be created first, but the app recipe *is* supposed to run first.
  user    node[:scalr_server][:app][:user]
  group   node[:scalr_server][:app][:user]
  returns 0
  timeout 36000
  command "#{node[:scalr_server][:install_root]}/embedded/bin/php upgrade.php"
  cwd     "#{scalr_bundle_path node}/app/bin"
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
end


# Initialize Scalr administrator

default_username = 'admin'
hashed_default_password = Digest::SHA2.new(256).update('admin').hexdigest

new_username = node[:scalr_server][:app][:admin_user]
hashed_new_password = Digest::SHA2.new(256).update(node[:scalr_server][:app][:admin_password]).hexdigest

admin_id = 1

# The queries below are idempotent and only change the password in case it was set to the default.
mysql_database 'set admin username' do
  description     "Set Scalr admin username (if not changed)"
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET email='#{new_username}' WHERE id=#{admin_id} AND email='#{default_username}'"
  action          :query
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
end

mysql_database 'set admin password' do
  description     "Set Scalr admin password (if not changed)"
  connection      mysql_scalr_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET password='#{hashed_new_password}' WHERE id=#{admin_id} AND password='#{hashed_default_password}'"
  action          :query
  not_if          { node[:scalr_server][:app][:skip_db_initialization] }
end
