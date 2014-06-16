require 'digest'

#TODO: There's a bit of copy-paste going on here!
mysql_conn_params = "-h'#{node[:scalr][:database][:host]}' -u'#{node[:scalr][:database][:username]}' -p'#{node[:scalr][:database][:password]}' -D'#{node[:scalr][:database][:scalr_dbname]}'"

h = Digest::SHA256.new
h.update node[:scalr][:admin][:password]

admin_id = 1

execute "Set Admin Username" do
  command "mysql #{mysql_conn_params} -e \"UPDATE account_users SET email='#{node[:scalr][:admin][:username]}' WHERE id=#{admin_id}\""
  not_if "mysql #{mysql_conn_params} -e \"SELECT id FROM account_users WHERE id=#{admin_id} AND email='#{node[:scalr][:admin][:username]}'\" | grep 1"  # Data from Scalr 4.5.1
end

execute "Set Admin Password" do
  command "mysql #{mysql_conn_params} -e \"UPDATE account_users SET password='#{h.hexdigest}' WHERE id=#{admin_id}\""
  not_if "mysql #{mysql_conn_params} -e \"SELECT id FROM account_users WHERE id=#{admin_id} AND password='#{h.hexdigest}'\" | grep 1"  # Data from Scalr 4.5.1
end
