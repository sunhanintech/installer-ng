[app, proxy, web, mysql, cron, service, rrd].each do |mod|
  mod[:enable] = false
end

memcached[:enable] = true
