require 'digest'

# Add MySQL user
user node[:scalr_server][:mysql][:user] do
  home   data_dir_for(node, 'mysql')  # TODO - Check if this works when it doesn't exist.
  system true
end


# Create MySQL configuration dir and file
directory etc_dir_for(node, 'mysql') do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
end

template "#{etc_dir_for node, 'mysql'}/my.cnf" do
  source    'mysql/my.cnf.erb'
  owner     'root'
  group     'root'
  mode      0644
  helpers(Scalr::PathHelper)
  notifies  :restart, 'supervisor_service[mysql]', :delayed
# TODO - Warn user if MySQL tz != UTC? We default to 00:00 here.
end


# Bootstrap MySQL database
directory "#{data_dir_for node, 'mysql'}" do
  owner     node[:scalr_server][:mysql][:user]
  group     node[:scalr_server][:mysql][:user]
  mode      0755
  recursive true
end


# Create MySQL run and log dirs
directory run_dir_for(node, 'mysql') do
  owner     node[:scalr_server][:mysql][:user]
  group     node[:scalr_server][:mysql][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'mysql') do
  owner     node[:scalr_server][:mysql][:user]
  group     node[:scalr_server][:mysql][:user]
  mode      0755
  recursive true
end

# Note that this runs at compile time.

is_bootstrapping = ! ::File.directory?("#{data_dir_for node, 'mysql'}/mysql")

execute 'mysql_install_db' do
  command "#{node[:scalr_server][:install_root]}/embedded/scripts/mysql_install_db" \
          " --defaults-file=#{etc_dir_for node, 'mysql'}/my.cnf" \
          " --basedir=#{node[:scalr_server][:install_root]}/embedded" \
          " --user=#{node[:scalr_server][:mysql][:user]}"
  only_if { is_bootstrapping }
end

# Launch MySQL
# View: http://supervisord.org/subprocess.html#pidproxy-program
# TODO - Consider reloading?
supervisor_service 'mysql' do
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/pidproxy" \
                  " #{run_dir_for node, 'mysql'}/mysql.pid" \
                  " #{node[:scalr_server][:install_root]}/embedded/bin/mysqld_safe" \
                  " --defaults-file=#{etc_dir_for node, 'mysql'}/my.cnf" \
                  " --basedir=#{node[:scalr_server][:install_root]}/embedded"
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/mysql.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/mysql.err"
  action          [:enable, :start]
  autostart       true
end


# Set up initial passwords and other MySQL initialization tasks
mysql_database 'set_root_passwords' do
  connection      mysql_base_params(node).merge!({:username => 'root'})
  database_name   'mysql'  # This MUST be set, otherwise Chef happily just discards our request because the null database doesn't exist.
  sql             "UPDATE mysql.user SET Password = PASSWORD('#{node[:scalr_server][:mysql][:root_password]}') WHERE User = 'root';" \
                  ' FLUSH PRIVILEGES'
  action          :query
  retries         10  # Give MySQL some time to come online.
  only_if         { is_bootstrapping }
 # We can't use notify ... here, because FLUSH PRIVILEGES must be called before our password can work.
end

mysql_database 'remove_anonymous_users' do
  connection      mysql_root_params(node)
  database_name   'mysql'
  sql             "DELETE FROM mysql.user WHERE User = ''; FLUSH PRIVILEGES;"
  action          :query
  only_if         { is_bootstrapping }
end

mysql_database 'remove_access_to_test_databases' do
  connection      mysql_root_params(node)
  database_name   'mysql'
  sql             "DELETE FROM mysql.db WHERE Db LIKE 'test%'; FLUSH PRIVILEGES;"
  action          :query
  only_if         { is_bootstrapping }
end


# Set up actual Scalr users

mysql_database_user node[:scalr_server][:mysql][:scalr_user] do
  connection        mysql_root_params(node)
  password          node[:scalr_server][:mysql][:scalr_password]
  host              node[:scalr_server][:mysql][:scalr_allow_connections_from]
  action            :create
  retries           is_bootstrapping ? 0 : 10
end

# The analytics database is not useful on an old Scalr version, but that's
# fine -- we create it anyway so that we don't need to know which version
# is being deployed to support MySQL
scalr_databases = [
  node[:scalr_server][:mysql][:scalr_dbname],
  node[:scalr_server][:mysql][:analytics_dbname],
]

scalr_databases.each do |scalr_database|
  mysql_database scalr_database do
    connection  mysql_root_params(node)
    action      :create
  end

  mysql_database_user node[:scalr_server][:mysql][:scalr_user] do
    connection    mysql_root_params(node)
    database_name scalr_database
    action        :grant
  end
end


# Load database structure and data

# Load data only if no upgrade data is there (>= 5.0), or rely on some other indicator if upgrade data is unavailable (< 5.0)
if has_migrations? node
  canary_table = 'upgrades'
else
  canary_table = 'ipaccess'
end

mysql_database 'load scalr database structure' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/structure.sql").read }
  not_if          { mysql_has_table?(mysql_root_params(node), node[:scalr_server][:mysql][:scalr_dbname], canary_table) }
  action          :query
end

mysql_database 'load scalr database data' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{scalr_bundle_path node}/sql/data.sql").read }
  not_if          { mysql_has_rows?(mysql_user_params(node), node[:scalr_server][:mysql][:scalr_dbname], canary_table) }
  action          :query
end

if has_cost_analytics? node
  mysql_database 'load analytics database structure' do
    connection      mysql_user_params(node)
    database_name   node[:scalr_server][:mysql][:analytics_dbname]
    sql             { ::File.open("#{scalr_bundle_path node}/sql/analytics_structure.sql").read }
    not_if          { mysql_has_table?(mysql_root_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
    action          :query
  end

  mysql_database 'load analytics database data' do
    connection      mysql_user_params(node)
    database_name   node[:scalr_server][:mysql][:analytics_dbname]
    sql             { ::File.open("#{scalr_bundle_path node}/sql/analytics_data.sql").read }
    not_if          { mysql_has_rows?(mysql_user_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
    action          :query
  end
end

if has_migrations? node
  execute 'Upgrade Scalr Database' do
    user    node[:scalr_server][:app][:user]
    group   node[:scalr_server][:app][:user]
    returns 0
    command "#{node[:scalr_server][:install_root]}/embedded/bin/php upgrade.php"
    cwd     "#{scalr_bundle_path node}/app/bin"
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
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET email='#{new_username}' WHERE id=#{admin_id} AND email='#{default_username}'"
  action          :query
end

mysql_database 'set admin password' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET password='#{hashed_new_password}' WHERE id=#{admin_id} AND password='#{hashed_default_password}'"
  action          :query
end
