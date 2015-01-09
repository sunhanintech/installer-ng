include_recipe 'database::mysql'

# Load data only if no upgrade data is there (>= 5.0), or rely on some other indicator if upgrade data is unavailable (< 5.0)
if has_migrations? node
  canary_table = 'upgrades'
else
  canary_table = 'ipaccess'
end

mysql_database 'load scalr database structure' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{node[:scalr][:core][:location]}/sql/structure.sql").read }
  not_if          { mysql_has_table?(mysql_root_params(node), node[:scalr_server][:mysql][:scalr_dbname], canary_table) }
  action          :query
end

mysql_database 'load scalr database data' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             { ::File.open("#{node[:scalr][:core][:location]}/sql/data.sql").read }
  not_if          { mysql_has_rows?(mysql_user_params(node), node[:scalr_server][:mysql][:scalr_dbname], canary_table) }
  action          :query
end

if has_cost_analytics? node
  mysql_database 'load analytics database structure' do
    connection      mysql_user_params(node)
    database_name   node[:scalr_server][:mysql][:analytics_dbname]
    sql             { ::File.open("#{node[:scalr][:core][:location]}/sql/analytics_structure.sql").read }
    not_if          { mysql_has_table?(mysql_root_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
    action          :query
  end

  mysql_database 'load analytics database data' do
    connection      mysql_user_params(node)
    database_name   node[:scalr_server][:mysql][:analytics_dbname]
    sql             { ::File.open("#{node[:scalr][:core][:location]}/sql/analytics_data.sql").read }
    not_if          { mysql_has_rows?(mysql_user_params(node), node[:scalr_server][:mysql][:analytics_dbname], 'upgrades') }
    action          :query
  end
end

if has_migrations? node
  execute 'Upgrade Scalr Database' do
    user    node[:scalr][:core][:users][:service]
    group   node[:scalr][:core][:group]
    returns 0
    command 'php upgrade.php'
    cwd     "#{node[:scalr][:core][:location]}/app/bin"
  end
end
