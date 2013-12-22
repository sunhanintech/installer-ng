node[:phpdeps][:ldap].each do |pkg|
    package pkg do
      action :install
    end
end

# Symlink broken library
#TODO Only on Ubuntu?
libldap = 'libldap.so'

link "/usr/lib/#{libldap}" do
  to "/usr/lib/x86_64-linux-gnu/#{libldap}"
end
