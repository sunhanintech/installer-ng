line = 'kernel.msgmnb = 524288'

execute 'reload-sysctl' do
  description "Reload sysctl configuration"
  command '/sbin/sysctl -p /etc/sysctl.conf || true'
  action :nothing
end

ruby_block 'do-sysctl-conf' do
  description "Generate sysctl configuration (/etc/sysctl.conf)"
  block do
    file = Chef::Util::FileEdit.new('/etc/sysctl.conf')
    file.insert_line_if_no_match(Regexp.escape(line), line)
    file.write_file
  end

  notifies :run, 'execute[reload-sysctl]', :immediately
end
