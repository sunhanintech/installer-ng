# plugin directories

# Config dir
directory etc_dir_for(node, 'httpd') + '/plugins' do
  description "Create directory (" + etc_dir_for(node, 'httpd') + "/plugins)"
  owner     'root'
  group     'root'
  mode      0755
end

# Data fir
directory var_dir_for(node, 'wsgi') do
  description "Create directory (" + var_dir_for(node, 'wsgi') + ")"
  owner     'root'
  group     'root'
  mode      0755
end
