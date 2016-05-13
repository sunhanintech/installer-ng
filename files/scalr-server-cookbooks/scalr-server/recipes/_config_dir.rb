directory node[:scalr_server][:config_dir] do
  description 'Creating directory (' + node[:scalr_server][:config_dir] + ')'
  owner   'root'
  group   'root'
  mode    0775
  action :nothing
end.run_action(:create)
