node[:phpdeps][:ldap].each do |pkg|
    package pkg do
      action :install
    end
end

# Symlink broken library
#TODO Only on Ubuntu?

%W{libldap.so liblber.so}.each do |lib|
  link "/usr/lib/#{lib}" do
    to "/usr/lib/x86_64-linux-gnu/#{lib}"
  end
end
