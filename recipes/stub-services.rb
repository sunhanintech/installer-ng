# We need to define the service init files before we restart those,
# otherwise, when we attempt a delayed restart, Chef will complain hat
# the files do not exist.
#
# Of course, we won't actually ever be using those dummy files.
#
# We don't actually the create the right files because at this point,
# we still don't know where Scalr is installed, so we can't succesfully
# complete those files.

node[:scalr][:services].each do |srv|
  init_file = "/etc/init.d/#{srv[:service_name]}"  # Some duplication here..

  file init_file do
    mode    0755
    owner   "root"
    group   "root"
    action  :create_if_missing
  end
end
