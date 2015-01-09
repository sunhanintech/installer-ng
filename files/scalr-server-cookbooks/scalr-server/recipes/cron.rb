php = '/usr/bin/php -q'

# Cron execution framework changes in Scalr 5.2.
if Gem::Dependency.new('scalr', '>= 5.2').match?('scalr', node[:scalr][:package][:version])
  cron_d 'scalr_service' do
    hour '*'
    minute '*'
    user    node[:scalr][:core][:users][:service]
    path    node[:scalr][:cron][:path]
    command "#{php} #{node[:scalr][:core][:location]}/app/cron/service.php >> #{node[:scalr][:core][:log_dir]}/service.log"
  end
end

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
