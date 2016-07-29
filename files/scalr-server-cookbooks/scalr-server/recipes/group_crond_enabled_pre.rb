# TODO - cron user.
# Create logging directory
directory "#{log_dir_for node, 'crond'}" do
  description "Create directory (" + "#{log_dir_for node, 'crond'}" + ")"
  owner 'root'  # cron runs as root.
  group 'root'
  mode 0755
end

# Create all the cron wrapper scripts (to set environment, etc.), and cron files.
directory bin_dir_for(node, 'crond') do
  description "Create directory (" + bin_dir_for(node, 'crond') + ")"
  owner 'root'  # cron runs as root.
  group 'root'
  mode 0755
end

directory etc_dir_for(node, 'crond') do
  description "Create directory (" + etc_dir_for(node, 'crond') + ")"
  owner 'root'  # cron runs as root.
  group 'root'
  mode 0755
end

directory "#{etc_dir_for node, 'crond'}/cron.d" do
  description "Create directory (" + "#{etc_dir_for node, 'crond'}/cron.d" + ")"
  owner 'root'  # cron runs as root.
  group 'root'
  mode 0755
end

