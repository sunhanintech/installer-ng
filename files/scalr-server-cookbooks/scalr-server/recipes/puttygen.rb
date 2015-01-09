case node[:platform_family]

when 'rhel'
  package 'putty'
when 'debian'
  package 'putty-tools'
end
