[web, mysql, memcached, cron, service, rrd].each do |mod|
  mod[:enable] = false
end

app[:enable] = true
proxy[:enable] = true
