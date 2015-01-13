module Scalr
  module ServiceHelper
    def enabled_services(node)
      all_services = [
              {:service_name => 'msgsender', :service_module => 'msg_sender', :service_desc => 'Scalr Messaging Daemon',
               :service_extra_args => '', :run => { :daemon => true }},

              {:service_name => 'dbqueue', :service_module => 'dbqueue_event', :service_desc => 'Scalr DB Queue Event Poller',
               :service_extra_args => '', :run => { :daemon => true }},

              {:service_name => 'plotter', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Plotter',
               :service_extra_args => '--plotter', :run => { :daemon => true }},

              {:service_name => 'poller', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Poller',
               :service_extra_args => '--poller', :run => { :daemon => true }},

              {:service_name => 'szrupdater', :service_module => 'szr_upd_service', :service_desc => 'Scalarizr Update Client',
               :service_extra_args => '', :run => { :daemon => true }},

              {:service_name => 'analytics_poller', :service_module => 'analytics_poller', :service_desc => 'Scalr Analytics Poller',
               :service_extra_args => '', :run => { :daemon => true }},

              {:service_name => 'analytics_processor', :service_module => 'analytics_processing', :service_desc => 'Scalr Analytics Processor',
               :service_extra_args => '', :run => { :daemon => true }},
          ]

      enabled_attr = node[:scalr_server][:worker][:enable]
      if enabled_attr.kind_of?(Array)
        # TODO - Might want to warn if one of the enabled services doesn't exist.
        # If this is an array, then these are the services we want to enable
        all_services.keep_if { |svc|
          enabled_attr.include? svc[:service_name]
        }
      else
        # If not, assume it's a boolean (meaning "all services" or "no services")
        enabled_attr ? all_services : []
      end
    end

    def enabled_crons(node)
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
          {:hour => '*/12',  :minute => '0',    :ng => false,  :name => 'CloudPricing'},
          {:hour => '1',     :minute => '0',    :ng => false,  :name => 'AnalyticsNotifications'},
      ]

      all_crons.concat %w{SzrMessagingAll SzrMessagingBeforeHostUp SzrMessagingHostInit SzrMessagingHostUp}.collect {
           |name| {:hour => '*', :minute => '*/2', :ng => false, :name => name}
       }

      enabled_attr = node[:scalr_server][:cron][:enable]
      if enabled_attr.kind_of?(Array)
        # TODO - Might want to warn if one of the enabled crons doesn't exist.
        # If this is an array, then these are the services we want to enable
        all_crons.keep_if { |cron|
          enabled_attr.include? cron[:name]
        }
      else
        # If not, assume it's a boolean (meaning "all services" or "no services")
        enabled_attr ? all_crons : []
      end
    end

    # Helper to tell Apache whether to serve graphics #
    def apache_serve_graphics(node)

      # Check for the two services
      expected_services = %w{plotter poller}
      unless (enabled_services(node).collect { |service| service[:service_name] } & expected_services) == expected_services
        return false
      end

      # Check for rrd
      unless node[:scalr_server][:rrd][:enable]
        return false
      end

      true
    end

  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::ServiceHelper)
  Chef::Recipe.send(:include, Scalr::ServiceHelper)
  Chef::Resource.send(:include, Scalr::ServiceHelper)
  Chef::Provider.send(:include, Scalr::ServiceHelper)
end
