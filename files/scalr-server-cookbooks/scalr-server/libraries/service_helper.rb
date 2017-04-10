require_relative './path_helper'

module Scalr
  module ServiceHelper
    include Scalr::PathHelper

    #############
    # Utilities #
    #############

    def _filter_enabled(node, mod, lst)
      enable = enable_module? node, mod
      disable_override = node[:scalr_server][mod][:disable]

      if enable.kind_of?(Array)
        # If this is a list, then it means it's a list of names of services that should be enabled.
        lst.select { |obj|
          enable.include?(obj[:name])
        }
        # TODO - Check if a service doesn't exist!
      else
        # Otherwise, it either means all or none.
        enable ? lst : []
      end.select { |obj|
        # Remove everything where disable overrides enable.
        not disable_override.include? obj[:name]
      }
    end

    def _filter_disabled(node, mod, lst)
      exclude = _filter_enabled(node, mod, lst).collect {|svc| svc[:name]}
      lst.reject { |svc|
        exclude.include? svc[:name]
      }
    end

    ############
    # Services #
    ############

    def _all_services
      [
          {
              :name => 'msgsender', :service_style => :python,
              :service_module => 'msg_sender', :service_extra_args => '',
          },

          {
              :name => 'dbqueue', :service_style => :python,
              :service_module => 'dbqueue_event', :service_extra_args => '',
          },

          {
              :name => 'plotter', :service_style => :python,
              :service_module => 'load_statistics', :service_extra_args => '--plotter',
          },

          {
              :name => 'poller', :service_style => :python,
              :service_module => 'load_statistics', :service_extra_args => '--poller',
          },

          {
              :name => 'szrupdater', :service_style => :python,
              :service_module => 'szr_upd_service', :service_extra_args => '',
          },

          {
              :name => 'analytics_poller', :service_style => :python,
              :service_module => 'analytics_poller', :service_extra_args => '',
          },

          {
              :name => 'analytics_processor', :service_style => :python,
              :service_module => 'analytics_processing', :service_extra_args => '',
          },

          {
              :name => 'analytics_notifications', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'cloud_poller', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'cloud_poller2', :service_style => :php,
              :service_config => {
                  :replicate => {
                      :type => ['credentials']
                  }
              },
          },

          {
              :name => 'service_health_monitoring', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'cloud_pricing', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'db_msr_maintenance', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'images_builder', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'images_cleanup', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'lease_manager', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'rotate', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'scalarizr_messaging', :service_style => :php,
              :service_config => {
                  :replicate => {
                      :type => %w(HostInit BeforeHostUp HostUp)
                  }
              },
          },

          {
              :name => 'scaling', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'scheduler', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'server_status_manager', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'server_terminate', :service_style => :php,
              :service_config => {},
          },

	  {
              :name => 'platform_usage_processor', :service_style => :php,
              :service_config => {},
          },

          {
              :name => 'dns_manager', :service_style => :php,
              :service_config => {},
          },
      ]
    end

    def _services_for_style(style)
      _all_services.keep_if { |svc|
        svc[:service_style] == style
      }
    end

    def enabled_services(node, style)
      _filter_enabled(node, :service, _services_for_style(style))
    end

    def disabled_services(node, style)
      _filter_disabled(node, :service, _services_for_style(style))
    end

    def _historical_crons
      # These cron jobs have been removed from Scalr, but we have to keep them here so that, upon an update,
      # they get removed.

      all_crons = [
          {:hour => '*',    :minute => '*',    :ng => false, :name => 'Scheduler'},
          {:hour => '*',    :minute => '*/5',  :ng => false, :name => 'UsageStatsPoller'},
          {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Scaling'},
          {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'BundleTasksManager'},
          {:hour => '*',    :minute => '*/15', :ng => true,  :name => 'MetricCheck'},
          {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Poller'},
          {:hour => '*',    :minute => '*/20', :ng => false, :name => 'RolesQueue'},
          {:hour => '*',    :minute => '*/5',  :ng => true,  :name => 'DbMsrMaintenance'},
          {:hour => '*',    :minute => '*/20', :ng => true,  :name => 'LeaseManager'},
          {:hour => '*',    :minute => '*',    :ng => true,  :name => 'ServerTerminate'},
          {:hour => '*/5',  :minute => '0',    :ng => false, :name => 'RotateLogs'},
          {:hour => '*/12', :minute => '0',    :ng => false, :name => 'CloudPricing'},
          {:hour => '1',    :minute => '0',    :ng => false, :name => 'AnalyticsNotifications'},
          {:hour => '*',    :minute => '*',    :ng => false, :name => 'DNSManagerPoll'},
      ]

      all_crons.concat %w{SzrMessagingAll SzrMessagingBeforeHostUp SzrMessagingHostInit SzrMessagingHostUp}.collect {
                           |name| {:hour => '*', :minute => '*/2', :ng => false, :name => name}
                       }

      all_crons
    end

    def _all_crons
      [
          {:hour => '*',    :minute => '*/10',  :ng => false, :name => 'EBSManager'},
      ]
    end

    def enabled_crons(node)
      _filter_enabled(node, :cron, _all_crons)
    end

    def disabled_crons(node)
      _filter_disabled(node, :cron, _all_crons) + _historical_crons
    end

    # Web helper

    def _all_web(node)
      [
          {
              :name => 'app',
              :root => "#{scalr_bundle_path node}/app/www",
              :bind_host => node[:scalr_server][:web][:app_bind_host],
              :bind_port => node[:scalr_server][:web][:app_bind_port],
          },
          {
              :name => 'graphics',
              :root => "#{data_dir_for node, 'service'}/graphics",
              :bind_host => node[:scalr_server][:web][:graphics_bind_host],
              :bind_port => node[:scalr_server][:web][:graphics_bind_port],
          },
      ]
    end

    def enabled_web(node)
      _filter_enabled(node, :web, _all_web(node))
    end

    def disabled_web(node)
      _filter_disabled(node, :web, _all_web(node))
    end

    # Generic module status helper #

    def enable_module?(node, mod)
      # Ensure that mod is a symbol
      mod = mod.to_sym

      # Supervisor is always enabled.
      if %i{supervisor dirs users sysctl}.include? mod
        return true
      end

      # Logrotate is always enabled.
      if mod == :logrotate
        return true
      end

      if mod == :crond
        return enable_module?(node, :cron) || enable_module?(node, :logrotate)
      end

      # App is enabled if anything that requires the app user is enabled.
      if mod == :app
        %w{cron rrd service web}.each do |dependent_mod|
          if enable_module?(node, dependent_mod)
            return true
          end
        end
        return false
      end

      # HTTPD is enabled if we have web or proxy or repos
      if mod == :httpd
        return enable_module?(node, :web) || enable_module?(node, :proxy) || enable_module?(node, :repos)
      end

      # Ordering matters a lot in the line below. We want to return the module's own enable settings so that if it's
      # not set to false, we get that one back (instead of a generic `true`). This then used in _filter enabled above.
      node[:scalr_server][mod][:enable] || node[:scalr_server][:enable_all]
    end

    # Service status helpers #

    # From: https://github.com/poise/supervisor/blob/master/providers/service.rb
    def service_status(node, svc)
      cmd = "#{node[:scalr_server][:install_root]}/embedded/bin/supervisorctl -c #{etc_dir_for node, 'supervisor'}/supervisord.conf status"
      result = Mixlib::ShellOut.new(cmd).run_command
      match = result.stdout.match("(^#{svc}(\\:\\S+)?\\s*)([A-Z]+)(.+)")
      if match.nil?
        'UNAVAILABLE'
      else
        match[3]
      end
    end

    def service_exists?(node, svc)
      File.exist?("#{node['supervisor']['dir']}/#{svc}.conf")
    end

    def service_is_up?(node, svc)
      service_exists?(node, svc) && (%w{RUNNING STARTING}.include? service_status(node, svc))
    end


    #####################
    # Memcached helpers #
    #####################

    def memcached_servers(node)
      if node[:scalr_server][:app][:memcached_host].nil? && node[:scalr_server][:app][:memcached_port].nil?
        node[:scalr_server][:app][:memcached_servers]
      else
        ["#{node[:scalr_server][:app][:memcached_host]}:#{node[:scalr_server][:app][:memcached_port]}",]
      end
    end

    def memcached_enable_sasl?(node)
      if node[:scalr_server][:memcached][:enable_sasl].nil?
        return node[:scalr_server][:memcached][:bind_host] != '127.0.0.1'
      end
      !! node[:scalr_server][:memcached][:enable_sasl]
    end

    #################
    # MySQL helpers #
    #################

    def mysql_bootstrap_status_file(node)
      "#{data_dir_for node, 'mysql'}/bootstrapped"
    end

    def mysql_bootstrapped?(node)
      if node[:mysql_bootstrap_status].nil?
        node.override[:mysql_bootstrap_status] = File.exists?(mysql_bootstrap_status_file node)
      end
      node[:mysql_bootstrap_status]
    end

    def mysql_timezone_status_file(node)
      "#{data_dir_for node, 'mysql'}/timezoned"
    end

    def mysql_timezoned?(node)
      File.exists?(mysql_timezone_status_file(node))
    end


    #################
    # SSMTP helpers #
    #################

    def ssmtp_use?(node)
      ! node[:scalr_server][:app][:email_mailserver].nil?
    end


    ###############
    # App Helpers #
    ###############

    # We renamed this setting to be consistent with the below. Use the old value if set, otherwise we use the new one.
    # We have to use .nil? instead of || ... here, because the timeout may reasonable be 0.
    def session_cookie_timeout(node)
      unless node[:scalr_server][:app][:session_cookie_lifetime].nil?
        return node[:scalr_server][:app][:session_cookie_lifetime]
      end
       node[:scalr_server][:app][:session_cookie_timeout]
    end

    def session_soft_timeout (node)
      node[:scalr_server][:app][:session_soft_timeout]
    end


    ####################
    # Endpoint helpers #
    ####################

    def graphics_scheme(node)
      node[:scalr_server][:routing][:graphics_scheme] || node[:scalr_server][:routing][:endpoint_scheme]
    end

    def graphics_host(node)
      node[:scalr_server][:routing][:graphics_host] || node[:scalr_server][:routing][:endpoint_host]
    end

    def plotter_scheme(node)
      node[:scalr_server][:routing][:plotter_scheme] || node[:scalr_server][:routing][:endpoint_scheme]

    end

    def plotter_host(node)
      node[:scalr_server][:routing][:plotter_host] || node[:scalr_server][:routing][:endpoint_host]
    end

    def plotter_port(node)
      node[:scalr_server][:routing][:plotter_port] || (node[:scalr_server][:routing][:endpoint_scheme] == 'https' ? 443 : 80)
    end

  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::ServiceHelper)
  Chef::Recipe.send(:include, Scalr::ServiceHelper)
  Chef::Resource.send(:include, Scalr::ServiceHelper)
  Chef::Provider.send(:include, Scalr::ServiceHelper)
end
