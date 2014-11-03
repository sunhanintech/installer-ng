# (Optional) MySQL installation
include_recipe "mysql::server"

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
