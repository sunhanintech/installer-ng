module Scalr
  module ServicesHelper
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

          {:service_name => 'szrupdater', :service_module => 'szr_upd_service', :service_desc => 'Scalarizr Update Client',
           :service_extra_args => '', :run => { :daemon => true }},

          {:service_name => 'analytics_poller', :service_module => 'analytics_poller', :service_desc => 'Scalr Analytics Poller',
           :service_extra_args => '', :run => { :daemon => true }},

          {:service_name => 'analytics_processor', :service_module => 'analytics_processing', :service_desc => 'Scalr Analytics Processor',
           :service_extra_args => '', :run => { :daemon => true }},
      ]

      # noinspection RubyUnnecessaryReturnValue
      out
    end

    def enabled_crons(node)
      out = [
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

      out.concat %w{SzrMessagingAll SzrMessagingBeforeHostUp SzrMessagingHostInit SzrMessagingHostUp}.collect {
           |name| {:hour => '*', :minute => '*/2', :ng => false, :name => name}
       }

      out
    end

  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::ServicesHelper)
  Chef::Recipe.send(:include, Scalr::ServicesHelper)
  Chef::Resource.send(:include, Scalr::ServicesHelper)
  Chef::Provider.send(:include, Scalr::ServicesHelper)
end
