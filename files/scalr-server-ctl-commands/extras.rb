add_command 'extras', 'Execute optional server preparation steps for Scalr (selinux, iptables, ntp, etc.)', 2 do
  status = run_command("chef-solo -c #{base_path}/embedded/cookbooks/solo.rb -j #{base_path}/embedded/cookbooks/extras.json")
  if status.success?
    log "#{display_name} Extras configured!"
    exit! 0
  else
    exit! 1
  end
end
