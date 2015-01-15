directory node[:scalr_server][:config_dir] do
  owner   'root'
  group   'root'
  mode    '0775'
  action :nothing
end.run_action(:create)
