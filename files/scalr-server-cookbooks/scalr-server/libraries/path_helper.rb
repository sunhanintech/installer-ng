module Scalr
  module PathHelper
    def scalr_bundle_path(node)
      "#{node[:scalr_server][:install_root]}/embedded/scalr"
    end

    def scalr_exec_path(node)
      [
          "#{node[:scalr_server][:install_root]}/bin",
          "#{node[:scalr_server][:install_root]}/embedded/sbin",
          "#{node[:scalr_server][:install_root]}/embedded/bin",
          "#{node[:scalr_server][:install_root]}/embedded/scripts",
          ENV['PATH']
      ].join(':')
    end

    # Common paths #

    def etc_dir_for(node, svc)
      "#{node[:scalr_server][:install_root]}/etc/#{svc}"
    end

    def run_dir_for(node, svc)
      "#{node[:scalr_server][:install_root]}/var/run/#{svc}"
    end

    def bin_dir_for(node, svc)
      "#{node[:scalr_server][:install_root]}/bin/#{svc}"
    end

    def log_dir_for(node, svc)
      "#{node[:scalr_server][:install_root]}/var/log/#{svc}"
    end

    def data_dir_for(node, svc)
      "#{node[:scalr_server][:install_root]}/var/lib/#{svc}"
    end

  end
end

# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::PathHelper)
  Chef::Recipe.send(:include, Scalr::PathHelper)
  Chef::Resource.send(:include, Scalr::PathHelper)
  Chef::Provider.send(:include, Scalr::PathHelper)
end
