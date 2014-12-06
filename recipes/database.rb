include_recipe "database::mysql"

#TODO: PORT

base_conn_params = "-h'#{node[:scalr][:database][:host]}' -u'#{node[:scalr][:database][:username]}' -p'#{node[:scalr][:database][:password]}'"
scalr_conn_params = "#{base_conn_params} -D'#{node[:scalr][:database][:scalr_dbname]}'"
analytics_conn_params = "#{base_conn_params} -D'#{node[:scalr][:database][:analytics_dbname]}'"

# Load the DB structure only if the upgrades table cannot be found (it's in the structure)
execute "Load Scalr Database Structure" do
  command "mysql #{scalr_conn_params} < #{node[:scalr][:core][:location]}/sql/structure.sql"
  not_if "[ $(mysql #{base_conn_params} -Ns -e \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='#{node[:scalr][:database][:scalr_dbname]}' AND table_name='upgrades';\") -gt 0 ]"
  # Only import structure if the upgrades table is not there yet (because it's always in the structure file)
end


# Load data only if no upgrade data is there (>= 5.0), or rely on some other indicator if upgrade data is unavailable (< 5.0)

if Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node.scalr.package.version)
  data_test_query = "SELECT COUNT(*) FROM upgrades;"
else
  data_test_query = "SELECT COUNT(*) FROM ipaccess;"
end

execute "Load Scalr Database Data" do
  command "mysql #{scalr_conn_params} < #{node[:scalr][:core][:location]}/sql/data.sql"
  not_if "[ $(mysql #{scalr_conn_params} -Ns -e \"#{data_test_query}\") -gt 0 ]"
  # Only import data if it's none at this point.
end

if Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node.scalr.package.version)
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
