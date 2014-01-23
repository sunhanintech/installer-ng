line = "kernel.msgmnb = 524288"

case node[:platform_family]
when 'rhel'
  ruby_block 'Set Sysctl Conf' do
    block do
      file = Chef::Util::FileEdit.new("/etc/sysctl.conf")
      file.insert_line_if_no_match(Regexp.escape(line), line)
      file.write_file
    end
  end

  execute 'sysctl -p' do
    # The ruby block can't indicate it didn't modify the file
    returns [0, 255]  # Unfortunately, there may be some invalid keys in
                      # there, and we can' crash the Chef run just
                      # because of that.
  end
when 'debian'
  sysctl_file = '/etc/sysctl.d/100-scalr.conf'

  file sysctl_file do
    content line
    mode 0644
    owner 'root'
    group 'root'
  end

  execute "sysctl -p #{sysctl_file}" do
    action :nothing
    subscribes :run, "file[#{sysctl_file}]", :delayed
  end
end
