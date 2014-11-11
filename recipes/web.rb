include_recipe 'apache2'

node['apache']['extra_modules'].each do |mod|
  include_recipe "apache2::mod_#{mod}"
end

# Disable a bunch of modules we don't need. Specifically, we don't want
# Apache's fancy indexing and icons

%w{alias autoindex}.each do |mod|
  apache_module mod do
    enable false
  end
end

web_app 'scalr' do
  template 'scalr-vhost.conf.erb'
  notifies :restart, "service[apache2]", :delayed
end

%w{000-default.conf default.conf 000-default-ssl.conf default-ssl.conf}.each do |site|
  apache_site site do
    enable    false
    notifies  :restart, "service[apache2]", :delayed
  end
end
