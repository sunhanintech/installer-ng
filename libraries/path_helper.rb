module Scalr
  module PathHelper

    def venv_python(node)
      "#{node[:scalr][:python][:venv]}/bin/python"
    end

    def venv_pip(node)
      "#{node[:scalr][:python][:venv]}/bin/pip"
    end

    def venv_build_path(node)
      # Here, it is crucial NOT to use ENV["PATH"], as this would include the Chef PATH, which ships its own pkg-config,
      # and will result in package builds failing in the virtual environment (because despite Chef having pkg-config, it will
      # not find our packages).
      "#{node.scalr.python.venv}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    end

  end
end

# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::PathHelper)
  Chef::Recipe.send(:include, Scalr::PathHelper)
  Chef::Resource.send(:include, Scalr::PathHelper)
  Chef::Provider.send(:include, Scalr::PathHelper)
end
