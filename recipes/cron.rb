#TODO: Reduce duplication user
php = '/usr/bin/php -q'
og_cmd = "#{php} #{node[:scalr][:core][:location]}/app/cron/cron.php"
ng_cmd = "#{php} #{node[:scalr][:core][:location]}/app/cron-ng/cron.php"

node[:scalr][:crons].each do |cron|
  cmd = cron[:ng] ? ng_cmd : og_cmd
  cron cron[:name] do
    user    node[:scalr][:core][:users][:service]
    hour    cron[:hour]
    minute  cron[:minute]
    command "#{cmd} --#{cron[:name]} >> #{node[:scalr][:core][:log_dir]}/cron.#{cron[:name]}.log"
  end
end
