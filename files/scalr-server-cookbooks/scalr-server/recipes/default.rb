# There's a bit of dark magic going on here, but the idea is that
# - We ensure our configuration dir is ready first
# - We check if a configuration file exists, and if it does, then we load it into the ScalrServer library. The
#   configuration file is basically #   an attributes file, except it must not have the leading default[:scalr_server].
#   For example: `default[:scalr_server][:app][:some_config] = ...` becomes `app[:some_config] = ...`.
# - We load the attributes generated by the ScalrServer library into our node attributes. This includes both attributes
#   loaded from the configuration file, and secrets (loaded from a separate JSON file, though they can be overridden in
#   the config file. Either way they'll be persisted in the JSON file).


# Helper functions

def process_recipe(r)
  begin
    include_recipe "scalr-server::#{r}"
  rescue Chef::Exceptions::RecipeNotFound
    log "loader-#{r}" do
      level :warn
      message "Did not load recipe: #{r}: recipe not found. OK TO CONTINUE."
    end
  end
end

def process_module(mod, stage)
  stage_ext = stage.nil? ? '' : "_#{stage}"
  if enable_module?(node, mod)
    process_recipe "group_#{mod}_enabled#{stage_ext}"
  else
    process_recipe "group_#{mod}_disabled#{stage_ext}"
  end
  process_recipe "group_#{mod}_always#{stage_ext}"
end

# Actual recipe

include_recipe 'scalr-server::_config_dir'

# Reads configuration from:
# + /etc/scalr-server/scalr-server.rb
# + /etc/scalr-server/scalr-server-local.rb
# + /etc/scalr-server/scalr-secrets.json
node.consume_attributes(ScalrServer.generate_config node)


all_modules = %i{dirs users mysql crond cron logrotate memcached app cron rrd service wsgi web proxy httpd sysctl}

# Stage 1 - Prepare before supervisor starts
all_modules.each do |mod|
  process_module mod, 'pre'
end

# Stage 2 - Launch Supervisor
process_module 'supervisor', nil

# Stage 3 - Post start steps
all_modules.each do |mod|
  process_module mod, 'post'
end

# Do re-branding if needed
remote_file "#{node[:scalr_server][:install_root]}/embedded/scalr/app/www/ui2/js/extjs-5.0/theme/images/topmenu/scalr-logo.png" do
  description "UI Branding (scalr-logo.png)"
  only_if { ::File.exist?('/etc/scalr-server/styles/scalr-logo.png') }
  source "file:///etc/scalr-server/styles/scalr-logo.png"
  owner 'scalr-app'
  group 'scalr-app'
  mode '0755'
  action :create
end

remote_file "#{node[:scalr_server][:install_root]}/embedded/scalr/app/www/ui2/js/extjs-5.0/theme/images/topmenu/scalr-logo-retina.png" do
  description "UI Branding (scalr-logo-retina.png)"
  only_if { ::File.exist?('/etc/scalr-server/styles/scalr-logo-retina.png') }
  source "file:///etc/scalr-server/styles/scalr-logo-retina.png"
  owner 'scalr-app'
  group 'scalr-app'
  mode '0755'
  action :create
end

remote_file "#{node[:scalr_server][:install_root]}/embedded/scalr/app/www/ui2/images/main-logo.png" do
  description "UI Branding (main-logo.png)"
  only_if { ::File.exist?('/etc/scalr-server/styles/main-logo.png') }
  source "file:///etc/scalr-server/styles/main-logo.png"
  owner 'scalr-app'
  group 'scalr-app'
  mode '0755'
  action :create
end

remote_file "#{node[:scalr_server][:install_root]}/embedded/scalr/app/www/ui2/images/main-logo-retina.png" do
  description "UI Branding (main-logo-retina.png)"
  only_if { ::File.exist?('/etc/scalr-server/styles/main-logo-retina.png') }
  source "file:///etc/scalr-server/styles/main-logo-retina.png"
  owner 'scalr-app'
  group 'scalr-app'
  mode '0755'
  action :create
end

remote_file "#{node[:scalr_server][:install_root]}/embedded/scalr/app/www/ui2/images/main-logo-bg.png" do
  description "UI Branding (main-logo-bg.png)"
  only_if { ::File.exist?('/etc/scalr-server/styles/main-logo-bg.png') }
  source "file:///etc/scalr-server/styles/main-logo-bg.png"
  owner 'scalr-app'
  group 'scalr-app'
  mode '0755'
  action :create
end

remote_file "#{node[:scalr_server][:install_root]}/embedded/scalr/app/www/ui2/images/main-logo-bg-retina.png" do
  description "UI Branding (main-logo-bg-retina.png)"
  only_if { ::File.exist?('/etc/scalr-server/styles/main-logo-bg-retina.png') }
  source "file:///etc/scalr-server/styles/main-logo-bg-retina.png"
  owner 'scalr-app'
  group 'scalr-app'
  mode '0755'
  action :create
end
