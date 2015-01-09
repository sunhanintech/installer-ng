module Scalr
  module VersionHelper

    def has_scalrpy2?(node)
      Gem::Dependency.new('scalr', '>= 5.1').match?('scalr', node[:scalr][:package][:version])
    end

    def has_migrations?(node)
      Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node[:scalr][:package][:version])
    end

    def has_cost_analytics?(node)
      Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node[:scalr][:package][:version])
    end

    def enabled_services(node)
      # Services that are always there
      out = [
          {:service_name => 'msgsender', :service_module => 'msg_sender', :service_desc => 'Scalr Messaging Daemon',
           :service_extra_args => '', :run => { :daemon => true }},

          {:service_name => 'dbqueue', :service_module => 'dbqueue_event', :service_desc => 'Scalr DB Queue Event Poller',
           :service_extra_args => '', :run => { :daemon => true }},

          {:service_name => 'plotter', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Plotter',
           :service_extra_args => '--plotter', :run => { :daemon => true }},

          {:service_name => 'poller', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Poller',
           :service_extra_args => '--poller', :run => { :daemon => true }},
      ]

      if Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node.scalr.package.version)
        # The Scalarizr Update and Cost Analytics Scalrpy were introduced in Scalr 5.0

        if Gem::Dependency.new('scalr', '>= 5.1').match?('scalr', node.scalr.package.version)
          # In Scalr 5.1, the Scarlrpy jobs all run as daemons instead of services.
          a_poller_run = {:daemon => true}
          a_processor_run = {:daemon => true}
          updater_args = ''
        else
          a_poller_run = {:cron => {:hour => '*', :minute => '*/5'}}
          a_processor_run = {:cron => {:hour => '*', :minute => '7,37'}}
          updater_args = '--interval=120'
        end

        extra_services = [
            {:service_name => 'szrupdater', :service_module => 'szr_upd_service', :service_desc => 'Scalarizr Update Client',
             :service_extra_args => updater_args, :run => { :daemon => true }},

            {:service_name => 'analytics_poller', :service_module => 'analytics_poller', :service_desc => 'Scalr Analytics Poller',
             :service_extra_args => '', :run => a_poller_run},

            {:service_name => 'analytics_processor', :service_module => 'analytics_processing', :service_desc => 'Scalr Analytics Processor',
             :service_extra_args => '', :run => a_processor_run},
        ]

        out.concat extra_services
      end

      out
    end

    def enabled_crons(node)
      dns_cron = {:hour => '*',    :minute => '*',    :ng => false, :name => 'DNSManagerPoll'}
      if Gem::Dependency.new('scalr', '>= 5.2').match?('scalr', node[:scalr][:package][:version])
        return [dns_cron]
      end

      out = [
          {:hour => '*',    :minute => '*',    :ng => false, :name => 'Scheduler'},
          {:hour => '*',    :minute => '*/5',  :ng => false, :name => 'UsageStatsPoller'},
          {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Scaling'},
          {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'BundleTasksManager'},
          {:hour => '*',    :minute => '*/15', :ng => true,  :name => 'MetricCheck'},
          {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Poller'},
          dns_cron,
          {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'EBSManager'},
          {:hour => '*',    :minute => '*/20', :ng => false, :name => 'RolesQueue'},
          {:hour => '*',    :minute => '*/5',  :ng => true,  :name => 'DbMsrMaintenance'},
          {:hour => '*',    :minute => '*/20', :ng => true,  :name => 'LeaseManager'},
          {:hour => '*',    :minute => '*',    :ng => true,  :name => 'ServerTerminate'},
          {:hour => '*/5',  :minute => '0',    :ng => false, :name => 'RotateLogs'},
      ]

      if Gem::Dependency.new('scalr', '>= 5.0').match?('scalr', node.scalr.package.version)
        analytics_crons = [
            {:hour => '*/12',  :minute => '0',    :ng => false,  :name => 'CloudPricing'},
            {:hour => '1',     :minute => '0',    :ng => false,  :name => 'AnalyticsNotifications'},
        ]

        messaging_cron_names = %w{SzrMessagingAll SzrMessagingBeforeHostUp SzrMessagingHostInit SzrMessagingHostUp}
        if Gem::Dependency.new('scalr', '< 5.1.1').match?('scalr', node.scalr.package.version)
          messaging_cron_names.concat %w{SzrMessagingAll2 SzrMessagingBeforeHostUp2 SzrMessagingHostInit2 SzrMessagingHostUp2 }
        end
      else
        analytics_crons = []
        messaging_cron_names = %w{SzrMessaging}
      end

      out.concat analytics_crons
      out.concat messaging_cron_names.collect {|name| {:hour => '*', :minute => '*/2', :ng => false, :name => name}}

      out
    end

  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::VersionHelper)
  Chef::Recipe.send(:include, Scalr::VersionHelper)
  Chef::Resource.send(:include, Scalr::VersionHelper)
  Chef::Provider.send(:include, Scalr::VersionHelper)
end
