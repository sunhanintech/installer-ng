[proxy, mysql, cron, service, rrd].each do |mod|
  mod[:enable] = false
end

app[:enable] = true
web[:enable] = ['app']
