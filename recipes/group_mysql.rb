# (Optional) MySQL installation
include_recipe "mysql::server"

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

scalr_databases = [node[:scalr][:database][:scalr_dbname]]
if Gem::Dependency.new(nil, '~> 5.0').match?(nil, node.scalr.package.version)
  scalr_databases.push(node[:scalr][:database][:analytics_dbname])
end

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

