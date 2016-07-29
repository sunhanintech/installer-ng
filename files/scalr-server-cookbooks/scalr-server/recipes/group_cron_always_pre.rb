# Split old cron to crond (deamon) and cron (cronjobs for Scalr app)
# We need to make sure to clean up old "cron" files and service
(disabled_crons(node) | enabled_crons(node)).each do |cron|

  file "#{etc_dir_for node, 'cron'}/cron.d/#{cron[:name]}" do
    description "Delete file (" + "#{etc_dir_for node, 'cron'}/cron.d/#{cron[:name]}" + ")"
    action :delete
    ignore_failure true
  end

  file "#{bin_dir_for node, 'cron'}/#{cron[:name]}" do
    description "Delete file (" + "#{bin_dir_for node, 'cron'}/#{cron[:name]}" + ")"
    action         :delete
    ignore_failure true
  end

  file "#{log_dir_for(node, 'cron')}/#{cron[:name]}.log" do
    description "Delete file (" + "#{log_dir_for(node, 'cron')}/#{cron[:name]}.log" + ")"
    action :delete
    ignore_failure true
  end

end

directory "#{etc_dir_for(node, 'cron')}/cron.d" do
  description      "Delete directory (" + "#{etc_dir_for(node, 'cron')}/cron.d" + ")"
  action           :delete
  ignore_failure   true
end

directory etc_dir_for(node, 'cron') do
  description      "Delete directory (" + etc_dir_for(node, 'cron') + ")"
  action           :delete
  ignore_failure   true
end

directory bin_dir_for(node, 'cron') do
  description      "Delete directory (" + bin_dir_for(node, 'cron') + ")"
  action           :delete
  ignore_failure   true
end

directory log_dir_for(node, 'cron') do
  description      "Delete directory (" + log_dir_for(node, 'cron') + ")"
  action           :delete
  ignore_failure   true
end

# Stop old cron service if running
supervisor_service 'cron' do
  description      "Stop old cron service"
  action service_is_up?(node, 'cron') ? [:stop, :disable] : [:disable]
end
