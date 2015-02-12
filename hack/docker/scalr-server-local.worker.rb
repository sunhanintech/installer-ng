# Enable all cron jobs, and enable all services except for the plotter and the poller.
# Those two services are deployed on the stats server instead.
cron[:enable] = true
service[:enable] = true
service[:disable] = ['plotter', 'plotter']
