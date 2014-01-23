if node[:platform_family] == 'debian'
  # We need to update the pid dir here, or we'll be unable to stop Apache.
  # We can't instruct the cookbook to ignore that failure and killall instead,
  # so here goes.
  template "#{node['apache']['dir']}/envvars" do
    source "apache2-envvars.erb"
  end

end

include_recipe 'apache2'

t = resources("template[apache2.conf]")
t.source "#{node[:platform_family]}-apache2.conf.erb"
t.cookbook "scalr-core"

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
