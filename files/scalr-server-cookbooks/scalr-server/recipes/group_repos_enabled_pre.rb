directory node[:scalr_server][:repos][:root] do
  description "Create directory (" + node[:scalr_server][:repos][:root] + ")"
  owner     'root'
  group     'root'
  mode      0755
end

#wget -m -np -nH -q --show-progress http://repo.scalr.net -P /opt/scalr-server/var/lib/repos/2016-11-30/
#ln -s 2016-11-30 current
