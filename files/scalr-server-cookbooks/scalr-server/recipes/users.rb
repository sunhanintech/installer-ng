# TODO - root user? (in group)

user node[:scalr_server][:app][:user] do
  system true
end

group node[:scalr_server][:group] do
  append true
  members [
              node[:scalr_server][:app][:user],
              node[:scalr_server][:mysql][:user]
          ]
end
