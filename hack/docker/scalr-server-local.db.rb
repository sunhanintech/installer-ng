[memcached, app, web, proxy, cron, service, rrd].each do |mod|
  mod[:enable] = false
end

mysql[:enable] = true
