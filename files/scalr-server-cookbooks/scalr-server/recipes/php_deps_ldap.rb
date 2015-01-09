case node[:platform]

when 'redhat', 'centos', 'fedora'
  package 'openldap-devel'

when 'ubuntu', 'debian'
  package 'libldap2-dev'
  # The LDAP libraries are not where PHP (or anyone, for that matter) expects them.
  # Fix it with a symlink
  %w{libldap.so liblber.so}.each do |lib|
    link "/usr/lib/#{lib}" do
      to "/usr/lib/x86_64-linux-gnu/#{lib}"
    end
  end

end

