include_recipe 'apache2'

node['apache']['extra_modules'].each do |mod|
  include_recipe "apache2::mod_#{mod}"
end

web_app 'scalr' do
  template 'scalr-vhost.conf.erb'
end

%w{000-default.conf default.conf 000-default-ssl.conf default-ssl.conf}.each do |site|
  apache_site site do
    enable false
  end
end
