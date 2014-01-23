cnf_file = "scalr-php-conf.ini"

node['php']['cnf_dirs'].each do |cnf_dir|
  template "#{cnf_dir}/#{cnf_file}" do
    source "#{cnf_file}.erb"
    owner "root"
    group "root"
    mode 0644
  end
end
