if node[:scalr_server][:web][:enable] || node[:scalr_server][:proxy][:enable]
  include_recipe 'scalr-server::_httpd_enabled'
else
  include_recipe 'scalr-server::_httpd_disabled'
end