# Install MySQL Gem
include_recipe 'database::mysql'

# Install MySQL
mysql_service 'default' do
  port                    node[:scalr_server][:mysql][:port].to_s  # The cookbook wants this to be... a string.
  server_root_password    node[:scalr_server][:mysql][:root_password]
  server_repl_password    node[:scalr_server][:mysql][:server_repl_password]
  server_debian_password  node[:scalr_server][:mysql][:server_debian_password]
  enable_utf8           'utf-8'  # And, somehow, the cookbook wants this to be a "truthy" string. Oh, well.
  action                :create
end

# Configure MySQL

mysql_database 'load tz info' do
  connection      mysql_root_params(node)
  database_name   'mysql'
  sql             {
    proc = Mixlib::ShellOut.new("mysql_tzinfo_to_sql /usr/share/zoneinfo/#{node[:rackspace_timezone][:config][:tz]} #{node[:rackspace_timezone][:config][:tz]}")
    proc.run_command
    proc.error!
    'TRUNCATE TABLE time_zone; TRUNCATE TABLE time_zone_name;' \
    + 'TRUNCATE TABLE time_zone_transition; TRUNCATE TABLE time_zone_transition_type;' \
    + proc.stdout
  }
  action          :query
end

template '/etc/mysql/conf.d/tz.cnf' do
  source    'mysql-tz.cnf.erb'
  mode      0755
  owner     'root'
  group     'root'
  notifies  :restart, "mysql_service[#{node['mysql']['service_name']}]", :delayed
end

mysql_database_user node[:scalr_server][:mysql][:scalr_user] do
  connection        mysql_root_params(node)
  password          node[:scalr_server][:mysql][:scalr_password]
  host              node[:scalr_server][:mysql][:scalr_allow_connections_from]
  action            :create
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

