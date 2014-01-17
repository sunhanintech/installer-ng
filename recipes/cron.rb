#TODO: Reduce duplication user
cmd = "/usr/bin/php -q #{node[:scalr][:core][:location]}/app/cron/cron.php"

cron "Scheduler" do
  user node[:scalr][:core][:users][:service]
  command "#{cmd} --Scheduler"
end

cron "UsageStatsPoller" do
  user node[:scalr][:core][:users][:service]
  minute "*/5"
  command "#{cmd} --UsageStatsPoller"
end

cron "Scaling" do
  user node[:scalr][:core][:users][:service]
  minute "*/2"
  command "#{cmd} --Scaling"
end

cron "SzrMessaging" do
  user node[:scalr][:core][:users][:service]
  minute "*/2"
  command "#{cmd} --SzrMessaging"
end

cron "BundleTasksManager" do
  user node[:scalr][:core][:users][:service]
  minute "*/2"
  command "#{cmd} --BundleTasksManager"
end

cron "MetricCheck" do
  user node[:scalr][:core][:users][:service]
  minute "*/15"
  command "#{cmd} --MetricCheck"
end

cron "Poller" do
  user node[:scalr][:core][:users][:service]
  minute "*/2"
  command "#{cmd} --Poller"
end

cron "DNSManagerPoll" do
  user node[:scalr][:core][:users][:service]
  command "#{cmd} --DNSManagerPoll"
end

cron "RotateLogs" do
  user node[:scalr][:core][:users][:service]
  minute "17"
  hour "5"
  command "#{cmd} --RotateLogs"
end

cron "EBSManager" do
  user node[:scalr][:core][:users][:service]
  minute "*/2"
  command "#{cmd} --EBSManager"
end

cron "RolesQueue" do
  user node[:scalr][:core][:users][:service]
  minute "*/20"
  command "#{cmd} --RolesQueue"
end

cron "DbMsrMaintenance" do
  user node[:scalr][:core][:users][:service]
  minute "*/5"
  command "#{cmd} --DbMsrMaintenance"
end

cron "LeaseManager" do
  user node[:scalr][:core][:users][:service]
  minute "*/20"
  command "#{cmd} --LeaseManager"
end

cron "ServerTerminate" do
  user node[:scalr][:core][:users][:service]
  minute "*/1"
  command "#{cmd} --ServerTerminate"
end
