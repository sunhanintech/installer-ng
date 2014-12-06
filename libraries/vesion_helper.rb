module Scalr
  module VersionHelper
    def scalrpy2?(node)
      Gem::Dependency.new('scalr', '>= 5.1').match?('scalr', node.scalr.package.version)
    end
  end
end


# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::VersionHelper)
  Chef::Recipe.send(:include, Scalr::VersionHelper)
  Chef::Resource.send(:include, Scalr::VersionHelper)
  Chef::Provider.send(:include, Scalr::VersionHelper)
end
