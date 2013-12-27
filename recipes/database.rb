include_recipe "mysql::server"
include_recipe "database::mysql"

root_conn_info = {
  :username => "root",
  :password => node['mysql']['server_root_password'],
  :host => node[:scalr][:database][:host],
  :port => node[:scalr][:database][:port],

}

mysql_database node[:scalr][:database][:dbname] do
  connection root_conn_info

  action :create
end

mysql_database_user node[:scalr][:database][:username] do
  connection root_conn_info

  password node[:scalr][:database][:password]
  host node[:scalr][:database][:client_host]
  database_name node[:scalr][:database][:dbname]

  action [:create, :grant]
end


mysql_conn_params = "-h#{node[:scalr][:database][:host]} -u#{node[:scalr][:database][:username]} -p#{node[:scalr][:database][:password]} -D#{node[:scalr][:database][:dbname]}"

execute "Load Scalr Database Structure" do
  command "mysql #{mysql_conn_params} < #{node[:scalr][:core][:location]}/sql/structure.sql"
  not_if "mysql #{mysql_conn_params} -e \"SHOW INDEX FROM events WHERE KEY_NAME = 'idx_type';\" | grep 'idx_type'"  # Latest migration from Scalr 4.5.1
end

execute "Load Scalr Database Data" do
  command "mysql #{mysql_conn_params} < #{node[:scalr][:core][:location]}/sql/data.sql"
  not_if "mysql #{mysql_conn_params} -e \"SELECT id FROM scaling_metrics WHERE name='LoadAverages'\" | grep 1"  # Data from Scalr 4.5.1
end
