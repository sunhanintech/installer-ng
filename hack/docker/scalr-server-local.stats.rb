[proxy, mysql, memcached, cron].each do |mod|
  mod[:enable] = false
end

app[:enable] = true
rrd[:enable] = true
web[:enable] = ['graphics']
service[:enable] = ['plotter', 'plotter']
