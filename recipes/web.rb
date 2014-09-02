include_recipe 'apache2'

node['apache']['extra_modules'].each do |mod|
  # Those don't have recipes in the apache2 cookbook
  apache_module mod
end

web_app 'scalr' do
  template 'scalr-vhost.conf.erb'
end

%w{000-default.conf default.conf 000-default-ssl.conf default-ssl.conf}.each do |site|
  apache_site site do
    enable false
  end
end
