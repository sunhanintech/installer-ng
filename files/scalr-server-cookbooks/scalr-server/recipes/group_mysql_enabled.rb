# Add MySQL user
user node[:scalr_server][:mysql][:user] do
  # TODO - Homes...
  system true
end


# Create MySQL configuration dir and file
directory etc_dir_for(node, 'mysql') do
  mode      0755
  recursive true
end

template "#{etc_dir_for node, 'mysql'}/my.cnf" do
  source 'my.cnf.erb'
  mode   0755
  helpers(Scalr::PathHelper)
# TODO - Warn user if MySQL tz != UTC? We default to 00:00 here.
end


# Bootstrap MySQL database
directory "#{data_dir_for node, 'mysql'}" do
  owner     node[:scalr_server][:mysql][:user]
  group     node[:scalr_server][:group]
  mode      0755
  recursive true
end


# Create MySQL run and log dirs
directory run_dir_for(node, 'mysql') do
  owner     node[:scalr_server][:mysql][:user]
  group     node[:scalr_server][:group]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'mysql') do
  owner     node[:scalr_server][:mysql][:user]
  group     node[:scalr_server][:group]
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

