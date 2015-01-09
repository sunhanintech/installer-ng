users = node[:scalr][:core][:users]

user users[:service]

user users[:web] do
  system true
end


group node[:scalr][:core][:group] do
  append true
  members users.values
end
