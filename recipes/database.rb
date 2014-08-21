include_recipe "mysql::server"
include_recipe "database::mysql"

root_conn_info = {
  :username => "root",
  :password => node['mysql']['server_root_password'],
  :host => node[:scalr][:database][:host],
  :port => node[:scalr][:database][:port],
}

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

#TODO: PORT

base_conn_params = "-h'#{node[:scalr][:database][:host]}' -u'#{node[:scalr][:database][:username]}' -p'#{node[:scalr][:database][:password]}'"
scalr_conn_params = "#{base_conn_params} -D'#{node[:scalr][:database][:scalr_dbname]}'"
analytics_conn_params = "#{base_conn_params} -D'#{node[:scalr][:database][:analytics_dbname]}'"

execute "Load Scalr Database Structure" do
  command "mysql #{scalr_conn_params} < #{node[:scalr][:core][:location]}/sql/structure.sql"
  not_if "[ $(mysql #{base_conn_params} -Ns -e \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='#{node[:scalr][:database][:scalr_dbname]}' AND table_name='upgrades';\") -gt 0 ]"
  # Only import structure if the upgrades table is not there yet (because it's always in the structure file)
end

execute "Load Scalr Database Data" do
  command "mysql #{scalr_conn_params} < #{node[:scalr][:core][:location]}/sql/data.sql"
  not_if "[ $(mysql #{scalr_conn_params} -Ns -e \"SELECT COUNT(*) FROM upgrades;\") -gt 0 ]"
  # Only import data if it's none at this point.
end

if Gem::Dependency.new(nil, '~> 5.0').match?(nil, node.scalr.package.version)
  # Load Analytics structure and data
  execute "Load Analytics Database Structure" do
    command "mysql #{analytics_conn_params} < #{node[:scalr][:core][:location]}/sql/analytics_structure.sql"
    not_if "[ $(mysql #{base_conn_params} -Ns -e \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='#{node[:scalr][:database][:analytics_dbname]}' AND table_name='upgrades';\") -gt 0 ]"
  end

  execute "Load Analytics Database Data" do
    command "mysql #{analytics_conn_params} < #{node[:scalr][:core][:location]}/sql/analytics_data.sql"
    not_if "[ $(mysql #{analytics_conn_params} -Ns -e \"SELECT COUNT(*) FROM upgrades;\") -gt 0 ]"
  end

  # Migrations were introduced in 5.0
  execute "Upgrade Scalr Database" do
    user node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    returns 0
    command "php upgrade.php"
    cwd "#{node[:scalr][:core][:location]}/app/bin"
  end
end

execute "Load MySQL TZ Info" do
  command "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -h'#{root_conn_info[:host]}' -u'#{root_conn_info[:username]}' -p'#{root_conn_info[:password]}' mysql"
end

template "/etc/mysql/conf.d/tz.cnf" do
  source "mysql-tz.cnf.erb"
  mode 0755
  owner "root"
  group "root"
  notifies :restart, "service[mysql]", :delayed
end
