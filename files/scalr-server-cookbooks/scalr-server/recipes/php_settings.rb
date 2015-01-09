cnf_file = "scalr-php-conf.ini"

# PHP configuration file
node['php']['cnf_dirs'].each do |cnf_dir|
  template "#{cnf_dir}/#{cnf_file}" do
    source "#{cnf_file}.erb"
    owner "root"
    group "root"
    mode 0644
  end
end

# Create PHP sessions path, ensure it has the right permissions
directory node['php']['session_save_path'] do
  owner     node[:scalr][:core][:users][:web]
  group     node[:scalr][:core][:group]
  mode      0755
  recursive true
  action    :create
end

