# Launch MySQL
# View: http://supervisord.org/subprocess.html#pidproxy-program
supervisor_service 'mysql' do
  description     "(Re)Start MySQL service"
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/pidproxy" \
                  " #{run_dir_for node, 'mysql'}/mysql.pid" \
                  " #{node[:scalr_server][:install_root]}/embedded/bin/mysqld_safe" \
                  " --defaults-file=#{etc_dir_for node, 'mysql'}/my.cnf" \
                  " --basedir=#{node[:scalr_server][:install_root]}/embedded"
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/mysql.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/mysql.err"
  action          [:enable, :start]
  autostart       true
  startsecs       10
  subscribes      :restart, 'user[mysql_user]' if service_is_up?(node, 'mysql')
end


# Set up initial passwords and other MySQL initialization tasks.
# We want this to always run (including when not bootstrapping), to avoid keeping an unset root password (and others)
# forever if it failed when we bootstrapped for the first time.
# TODO - Consider just adding a file to provide a flag.
root_nopass_params = mysql_admin_params node
root_nopass_params.delete(:password)

mysql_database 'set_root_passwords' do
  description     "Set MySQL root password"
  connection      root_nopass_params
  database_name   'mysql'  # This MUST be set, otherwise Chef happily just discards our request because the null database doesn't exist.
  sql             "UPDATE mysql.user SET Password = PASSWORD('#{node[:scalr_server][:mysql][:root_password]}') WHERE User = 'root' AND Password = '';" \
                  ' FLUSH PRIVILEGES'
  action          :query
  retries         10  # Give MySQL some time to come online.
  not_if          { mysql_bootstrapped? node }
end

mysql_database 'remove_anonymous_users' do
  description     "Remove annonymous MySQL user"
  connection      mysql_admin_params(node)
  database_name   'mysql'
  sql             "DELETE FROM mysql.user WHERE User = ''; FLUSH PRIVILEGES;"
  action          :query
  not_if          { mysql_bootstrapped? node }
end

mysql_database 'remove_access_to_test_databases' do
  description     "Remove access to MySQL test database"
  connection      mysql_admin_params(node)
  database_name   'mysql'
  sql             "DELETE FROM mysql.db WHERE Db LIKE 'test%'; FLUSH PRIVILEGES;"
  action          :query
  not_if          { mysql_bootstrapped? node }
end

# Insert time zone data into MySQL if missing
execute 'dump_timezone_to_sql' do
  description "Import timezone database to MySQL""
  command "#{node[:scalr_server][:install_root]}/embedded/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -S #{run_dir_for node, 'mysql' }/mysql.sock -u root -p#{node[:scalr_server][:mysql][:root_password]} mysql"
  not_if          { mysql_timezoned? node }
end


# Remote root

mysql_database_user 'root' do
  description "Enable remote root access to MySQL"
  connection  mysql_admin_params(node)
  password    node[:scalr_server][:mysql][:root_password]
  host        '%'
  action      node[:scalr_server][:mysql][:allow_remote_root] ? :grant : :drop
  retries     10  # Give MySQL some time to come online.
end

file mysql_bootstrap_status_file node do
  description "Create MySQL bootstrap placeholder file"
  mode     0644
  owner   'root'
  group   'root'
  action  :create_if_missing
end

file mysql_timezone_status_file node do
  description "Create MySQL timezone placeholder"
  mode     0644
  owner   'root'
  group   'root'
  action  :create_if_missing
end


# Set up Scalr and replication users.

mysql_database_user node[:scalr_server][:mysql][:scalr_user] do
  description       "Create MySQL scalr user"
  connection        mysql_admin_params(node)
  password          node[:scalr_server][:mysql][:scalr_password]
  host              node[:scalr_server][:mysql][:scalr_allow_connections_from]
  action            :create
end

mysql_database_user node[:scalr_server][:mysql][:repl_user] do
  description       "Create MySQL replication user"
  connection        mysql_admin_params(node)
  password          node[:scalr_server][:mysql][:repl_password]
  host              node[:scalr_server][:mysql][:repl_allow_connections_from]
  action            :create
end

mysql_database 'grant_replication_permissions' do
  description     "Enable replication permission to replication user"
  connection      mysql_admin_params(node)
  database_name   'mysql'
  sql             "GRANT REPLICATION SLAVE ON *.* TO '#{node[:scalr_server][:mysql][:repl_user]}'@'#{node[:scalr_server][:mysql][:repl_allow_connections_from]}'; FLUSH PRIVILEGES;"
  action          :query
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
    description "Create MySQL database (" + scalr_database + ")"
    connection  mysql_admin_params(node)
    action      :create
  end

  mysql_database_user node[:scalr_server][:mysql][:scalr_user] do
    description   "Create MySQL user (" + node[:scalr_server][:mysql][:scalr_user] + ") for database (" + scalr_database + ")"
    connection    mysql_admin_params(node)
    database_name scalr_database
    privileges    node[:scalr_server][:mysql][:scalr_privileges]
    action        :grant
  end
end

# Record bin log position
ruby_block 'record_bin_log_pos' do
  description "Save current binlog position (" + "#{data_dir_for node, 'mysql'}/binlog-bootstrap" + ")"
  block do
    File.open("#{data_dir_for node, 'mysql'}/binlog-bootstrap", 'w') do |f|
      f.puts(Chef::JSONCompat.to_json_pretty((mysql_master_status(mysql_admin_params(node)))))
    end
  end
  action  :run
  not_if  { mysql_bootstrapped? node }
  only_if { node[:scalr_server][:mysql][:binlog] }
end
