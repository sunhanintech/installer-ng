iptables_ng_rule 'scalr-web' do
  chain 'INPUT'
  table 'filter'
  rule "--protocol tcp --dport 80 --match state --state NEW --jump ACCEPT"  #TODO: Variabilize.
  action :create_if_missing
end

iptables_ng_rule 'scalr-graphics' do
  chain 'INPUT'
  table 'filter'
  rule "--protocol tcp --dport #{node[:scalr][:rrd][:port]} --match state --state NEW --jump ACCEPT"
  action :create_if_missing
end
