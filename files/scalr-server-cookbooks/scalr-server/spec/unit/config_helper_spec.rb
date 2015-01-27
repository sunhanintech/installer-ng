require 'spec_helper'
require 'yaml'

describe Scalr::ConfigHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ConfigHelper } }

  describe 'helper' do
    it 'should work' do
      node.set[:scalr_server][:mysql][:root_password] = 'rootpass'
      node.set[:scalr_server][:mysql][:scalr_user] = 'user'
      node.set[:scalr_server][:mysql][:scalr_password] = 'scalrpass'
      node.set[:scalr_server][:mysql][:scalr_dbname] = 'scalr'
      node.set[:scalr_server][:mysql][:analytics_dbname] = 'analytics'

      node.set[:scalr_server][:app][:email_from_address] = 'test@example.com'
      node.set[:scalr_server][:app][:email_from_name] = 'Test User'

      node.set[:scalr_server][:service][:enable] = true
      node.set[:scalr_server][:service][:plotter_bind_scheme] = 'http'
      node.set[:scalr_server][:service][:plotter_bind_host] = '0.0.0.0'
      node.set[:scalr_server][:service][:plotter_bind_port] = 8080

      node.set[:scalr_server][:routing][:mysql_host] = '127.0.0.1'
      node.set[:scalr_server][:routing][:mysql_port] = 3306

      node.set[:scalr_server][:routing][:endpoint_scheme] = 'http'
      node.set[:scalr_server][:routing][:endpoint_host] = 'test.com'

      node.set[:scalr_server][:routing][:graphics_scheme] = 'http'
      node.set[:scalr_server][:routing][:graphics_host] = 'test.com'
      node.set[:scalr_server][:routing][:graphics_path] = 'graphics'

      node.set[:scalr_server][:routing][:plotter_scheme] = 'http'
      node.set[:scalr_server][:routing][:plotter_host] = 'test.com'
      node.set[:scalr_server][:routing][:plotter_port] = 8080



      # Pretty basic test... We just assert that the config can be loaded.
      YAML.load(dummy_class.new.dump_scalr_configuration node)
    end
  end
end
