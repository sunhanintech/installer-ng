#TODO: Reduce duplication user
php = '/usr/bin/php -q'
og_cmd = "#{php} #{node[:scalr][:core][:location]}/app/cron/cron.php"
ng_cmd = "#{php} #{node[:scalr][:core][:location]}/app/cron-ng/cron.php"

enabled_crons(node).each do |cron|
  cmd = cron[:ng] ? ng_cmd : og_cmd
  cron_d cron[:name] do
    hour    cron[:hour]
    minute  cron[:minute]
    user    node[:scalr][:core][:users][:service]
    path    node[:scalr][:cron][:path]
    command "#{cmd} --#{cron[:name]} >> #{node[:scalr][:core][:log_dir]}/cron.#{cron[:name]}.log"
  end
end
