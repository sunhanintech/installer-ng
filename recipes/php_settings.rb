cnf_file = "scalr-php-conf.ini"

node['php']['cnf_dirs'].each do |cnf_dir|
  cookbook_file "#{cnf_dir}/#{cnf_file}" do
    source cnf_file
    owner "root"
    group "root"
    mode 0644
  end
end
