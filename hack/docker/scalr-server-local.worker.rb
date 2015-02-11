[proxy, web, mysql, memcached, rrd].each do |mod|
  mod[:enable] = false
end

app[:enable] = true
cron[:enable] = true
service[:enable] = %{
  msgsender dbqueue szrupdater analytics_poller analytics_processor
  analytics_notifications cloud_poller cloud_pricing db_msr_maintenance
  images_builder images_cleanup lease_manager rotate scalarizr_messaging
  scaling scheduler server_status_manager server_terminate
}
# TODO - :disable!
