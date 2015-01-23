module Scalr
  module ServiceHelper

    def _all_services
      [
          {
              :service_name => 'msgsender', :service_style => :python,
              :service_module => 'msg_sender', :service_extra_args => '',
          },

          {
              :service_name => 'dbqueue', :service_style => :python,
              :service_module => 'dbqueue_event', :service_extra_args => '',
          },

          {
              :service_name => 'plotter', :service_style => :python,
              :service_module => 'load_statistics', :service_extra_args => '--plotter',
          },

          {
              :service_name => 'poller', :service_style => :python,
              :service_module => 'load_statistics', :service_extra_args => '--poller',
          },

          {
              :service_name => 'szrupdater', :service_style => :python,
              :service_module => 'szr_upd_service', :service_extra_args => '',
          },

          {
              :service_name => 'analytics_poller', :service_style => :python,
              :service_module => 'analytics_poller', :service_extra_args => '',
          },

          {
              :service_name => 'analytics_processor', :service_style => :python,
              :service_module => 'analytics_processing', :service_extra_args => '',
          },

          {
              :service_name => 'cloud_poller', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'cloud_pricing', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'db_msr_maintenance', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'images_builder', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'images_cleanup', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'lease_manager', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'rotate', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'scalarizr_messaging', :service_style => :php,
              :service_config => {
                  :replicate => {
                      :type => %w(HostInit BeforeHostUp HostUp)
                  }
              },
          },

          {
              :service_name => 'scaling', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'scheduler', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'server_status_manager', :service_style => :php,
              :service_config => {},
          },

          {
              :service_name => 'server_terminate', :service_style => :php,
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
      enabled_services_attr = node[:scalr_server][:service][:enable]
      if enabled_services_attr.kind_of?(Array)
        # TODO - Might want to warn if one of the enabled services doesn't exist.
        # If this is an array, then these are the services we want to enable
        _services_for_style(style).keep_if { |svc|
          enabled_services_attr.include? svc[:service_name]
        }
      else
        # If not, assume it's a boolean (meaning "all services" or "no services")
        enabled_services_attr ? _services_for_style(style) : []
      end
    end

    def disabled_services(node, style)
      names_to_exclude = enabled_services(node, style).collect {|svc| svc[:service_name]}
      _services_for_style(style).reject { |svc|
        names_to_exclude.include? svc[:service_name]
      }
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
          {:hour => '*',    :minute => '*',    :ng => false, :name => 'DNSManagerPoll'},
          {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'EBSManager'},
          {:hour => '*',    :minute => '*/20', :ng => false, :name => 'RolesQueue'},
          {:hour => '*',    :minute => '*/5',  :ng => true,  :name => 'DbMsrMaintenance'},
          {:hour => '*',    :minute => '*/20', :ng => true,  :name => 'LeaseManager'},
          {:hour => '*',    :minute => '*',    :ng => true,  :name => 'ServerTerminate'},
          {:hour => '*/5',  :minute => '0',    :ng => false, :name => 'RotateLogs'},
          {:hour => '*/12', :minute => '0',    :ng => false, :name => 'CloudPricing'},
          {:hour => '1',    :minute => '0',    :ng => false, :name => 'AnalyticsNotifications'},
      ]

      all_crons.concat %w{SzrMessagingAll SzrMessagingBeforeHostUp SzrMessagingHostInit SzrMessagingHostUp}.collect {
                           |name| {:hour => '*', :minute => '*/2', :ng => false, :name => name}
                       }

      all_crons
    end

    def enabled_crons(node)
      []
    end

    def disabled_crons(node)
      _historical_crons
    end

    # Helper to tell Apache whether to serve graphics #

    def apache_serve_graphics(node)

      # Check for the two services
      expected_services = %w{plotter poller}
      unless (enabled_services(node, :python).collect { |service| service[:service_name] } & expected_services) == expected_services
        return false
      end

      # Check for rrd
      unless node[:scalr_server][:rrd][:enable]
        return false
      end

      true
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
      %w{RUNNING STARTING}.include? service_status(node, svc)
    end

    def should_notify_service?(node, svc)
      service_exists?(node, svc) && service_is_up?(node, svc)
    end

  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::ServiceHelper)
  Chef::Recipe.send(:include, Scalr::ServiceHelper)
  Chef::Resource.send(:include, Scalr::ServiceHelper)
  Chef::Provider.send(:include, Scalr::ServiceHelper)
end
