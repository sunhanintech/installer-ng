# As a side effect, this will generate ID and Cryptokey

node[:scalr][:core][:users].values.each do |usr|
  execute "Validate Scalr Install as #{usr}" do
    user usr
    group node[:scalr][:core][:group]
    returns 0
    command "php testenvironment.php"
    cwd "#{node[:scalr][:core][:location]}/app/www"
  end
end


id_file = "#{node[:scalr][:core][:location]}/app/etc/id"
mark_string = "ix"

execute "Mark Install" do
  command "echo \"#{mark_string}$(cat #{id_file})\" > #{id_file}"
  not_if {
    begin
      line = File.new(id_file).gets
      line[0, mark_string.length] == mark_string
    rescue
      false
    end
  }
end
