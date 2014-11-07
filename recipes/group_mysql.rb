# Install MySQL
include_recipe "mysql::server"

# Install MySQL Gem
include_recipe "database::mysql"

# Configure MySQL
root_conn_info = {
  :username => "root",
  :password => node['mysql']['server_root_password'],
  :host => node[:scalr][:database][:host],
  :port => node[:scalr][:database][:port],
}

execute "Load MySQL TZ Info" do
  command "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -h'#{root_conn_info[:host]}' -u'#{root_conn_info[:username]}' -p'#{root_conn_info[:password]}' mysql"
end

template "/etc/mysql/conf.d/tz.cnf" do
  source "mysql-tz.cnf.erb"
  mode 0755
  owner "root"
  group "root"
  notifies :restart, "mysql_service[#{node['mysql']['service_name']}]", :delayed
end

mysql_database_user node[:scalr][:database][:username] do
  connection root_conn_info

  password node[:scalr][:database][:password]
  host node[:scalr][:database][:client_host]

  action [:create]
end

# The analytics database is not useful on an old Scalr version, but that's
# fine -- we create it anyway so that we don't need to know which version
# is being deployed to support MySQL
scalr_databases = [
  node[:scalr][:database][:scalr_dbname],
  node[:scalr][:database][:analytics_dbname],
]

scalr_databases.each do |scalr_database|
  mysql_database scalr_database do
    connection root_conn_info
    action :create
  end

  mysql_database_user node[:scalr][:database][:username] do
    connection root_conn_info
    database_name scalr_database
    action [:grant]
  end
end

