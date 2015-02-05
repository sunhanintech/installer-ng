require_relative './path_helper'

module Scalr
  module ServiceHelper
    include Scalr::PathHelper

    #############
    # Utilities #
    #############

    def _filter_enabled(lst, attr)
      if attr.kind_of?(Array)
        # If the enabled attr is a list, then it means it's a list of names of services that should be enabled.
        lst.select { |obj|
          attr.include? obj[:name]
        }
        # TODO - Check if a service doesn't exist!
      else
        # Otherwise, it either means all or none.
        attr ? lst : []
      end
    end

    def _filter_disabled(lst, attr)
      exclude = _filter_enabled(lst, attr).collect {|svc| svc[:name]}
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
      ]
    end

    def _services_for_style(style)
      _all_services.keep_if { |svc|
        svc[:service_style] == style
      }
    end

    def enabled_services(node, style)
      _filter_enabled(_services_for_style(style), node[:scalr_server][:service][:enable])
    end

    def disabled_services(node, style)
      _filter_disabled(_services_for_style(style), node[:scalr_server][:service][:enable])
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

    def _all_crons
      [
          {:hour => '*',    :minute => '*',    :ng => false, :name => 'DNSManagerPoll'},
      ]
    end

    def enabled_crons(node)
      _filter_enabled(_all_crons, node[:scalr_server][:cron][:enable])
    end

    def disabled_crons(node)
      _filter_disabled(_all_crons, node[:scalr_server][:cron][:enable]) + _historical_crons
    end

    # Helper to tell Apache whether to serve graphics #

    def apache_serve_graphics(node)

      # Check for the two services
      expected_services = %w{plotter poller}
      unless (enabled_services(node, :python).collect { |service| service[:name] } & expected_services) == expected_services
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
      service_exists?(node, svc) && (%w{RUNNING STARTING}.include? service_status(node, svc))
    end

  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::ServiceHelper)
  Chef::Recipe.send(:include, Scalr::ServiceHelper)
  Chef::Resource.send(:include, Scalr::ServiceHelper)
  Chef::Provider.send(:include, Scalr::ServiceHelper)
end
