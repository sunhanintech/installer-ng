# Enable RRD, the web graphics submodule, and the plotter and poller service submodules.
rrd[:enable] = true
web[:enable] = ['graphics']
service[:enable] = ['plotter', 'poller']
