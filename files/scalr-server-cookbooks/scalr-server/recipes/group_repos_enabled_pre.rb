directory node[:scalr_server][:repos][:root] do
  description "Create directory (" + node[:scalr_server][:repos][:root] + ")"
  owner     'root'
  group     'root'
  mode      0755
end

directory node[:scalr_server][:repos][:root] + '/current' do
  description "Create directory (" + node[:scalr_server][:repos][:root] + "/current)"
  owner     'root'
  group     'root'
  mode      0755
end

directory node[:scalr_server][:repos][:root] + '/current/apt-plain' do
  description "Create directory (" + node[:scalr_server][:repos][:root] + "/current/apt-plain)"
  owner     'root'
  group     'root'
  mode      0755
end

directory node[:scalr_server][:repos][:root] + '/current/rpm' do
  description "Create directory (" + node[:scalr_server][:repos][:root] + "/current/rpm)"
  owner     'root'
  group     'root'
  mode      0755
end

directory node[:scalr_server][:repos][:root] + '/current/win' do
  description "Create directory (" + node[:scalr_server][:repos][:root] + "/current/win)"
  owner     'root'
  group     'root'
  mode      0755
end
