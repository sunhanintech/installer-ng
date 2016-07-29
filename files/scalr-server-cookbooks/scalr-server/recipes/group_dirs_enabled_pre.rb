# Build all dirs.
# Don't use recursive to ensure we work on systems with a restrictive umask.

[etc_dir(node), bin_dir(node), var_dir(node), run_dir(node), log_dir(node), data_dir(node)].each do |dir|
  directory dir do
    description "Create directory (" + dir + ")"
    owner     'root'
    group     'root'
    mode      0775
  end
end
