# As a side effect, this will generate the cryptokey

node[:scalr][:core][:users].values.each do |usr|
  execute "Validate Scalr Install as #{usr}" do
    user usr
    group node[:scalr][:core][:group]
    returns 0
    command "php testenvironment.php"
    cwd "#{node[:scalr][:core][:location]}/app/www"
  end
end

