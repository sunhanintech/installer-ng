require 'digest'

default_username = 'admin'
hashed_default_password = Digest::SHA2.new(256).update('admin').hexdigest

new_username = node[:scalr_server][:app][:admin_user]
hashed_new_password = Digest::SHA2.new(256).update(node[:scalr_server][:app][:admin_password]).hexdigest

admin_id = 1


# The queries below are idempotent and only change the password in case it was set to the default.

mysql_database 'set admin username' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET email='#{new_username}' WHERE id=#{admin_id} AND email='#{default_username}'"
  action          :query
end

mysql_database 'set admin password' do
  connection      mysql_user_params(node)
  database_name   node[:scalr_server][:mysql][:scalr_dbname]
  sql             "UPDATE account_users SET password='#{hashed_new_password}' WHERE id=#{admin_id} AND password='#{hashed_default_password}'"
  action          :query
end
