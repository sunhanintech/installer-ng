disabled_crons(node).each do |cron|

  file "#{bin_dir_for node, 'cron'}/#{cron[:name]}" do
    action :delete
  end

  file "#{etc_dir_for node, 'cron'}/cron.d/#{cron[:name]}" do
    action :delete
  end
end
