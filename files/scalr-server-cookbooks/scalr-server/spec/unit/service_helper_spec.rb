require 'spec_helper'

describe Scalr::ServiceHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ServiceHelper } }

  describe '#services' do
    it 'should return the right services' do
      node.set[:scalr_server][:service][:enable] = true
      node.set[:scalr_server][:service][:disable] = []

      python_services = dummy_class.new.enabled_services(node, :python).collect {|service| service[:name]}
      expect(python_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})

      php_services = dummy_class.new.enabled_services(node, :php).collect {|service| service[:name]}
      expect(php_services.length).to eq(14)
    end

    it 'should work implicitly' do
      node.set[:scalr_server][:enable_all] = true
      node.set[:scalr_server][:service][:enable] = false
      node.set[:scalr_server][:service][:disable] = []

      python_services = dummy_class.new.enabled_services(node, :python).collect {|service| service[:name]}
      expect(python_services.length).to eq(7)

      php_services = dummy_class.new.enabled_services(node, :php).collect {|service| service[:name]}
      expect(php_services.length).to eq(14)
    end

    it 'should support false' do
      node.set[:scalr_server][:service][:enable] = false
      node.set[:scalr_server][:service][:disable] = []
      expect(dummy_class.new.enabled_services(node, :python).length).to eq(0)
      expect(dummy_class.new.disabled_services(node, :python).length).to eq(7)
    end

    it 'should support filtered services' do
      node.set[:scalr_server][:service][:enable] = %w{plotter poller server_terminate images_builder scalarizr_messaging}
      node.set[:scalr_server][:service][:disable] = []
      expect(dummy_class.new.enabled_services(node, :python).length).to eq(2)
      expect(dummy_class.new.disabled_services(node, :python).length).to eq(5)

      expect(dummy_class.new.enabled_services(node, :php).length).to eq(3)
      expect(dummy_class.new.disabled_services(node, :php).length).to eq(11)
    end

    it 'should support disable' do
      node.set[:scalr_server][:service][:enable] = %w{plotter poller server_terminate images_builder scalarizr_messaging}
      node.set[:scalr_server][:service][:disable] = %w{plotter server_terminate}
      expect(dummy_class.new.enabled_services(node, :python).length).to eq(1)
      expect(dummy_class.new.disabled_services(node, :python).length).to eq(6)

      expect(dummy_class.new.enabled_services(node, :php).length).to eq(2)
      expect(dummy_class.new.disabled_services(node, :php).length).to eq(12)
    end

    it 'should support disable' do
      node.set[:scalr_server][:service][:enable] = true
      node.set[:scalr_server][:service][:disable] = %w{plotter poller images_builder}
      expect(dummy_class.new.enabled_services(node, :python).length).to eq(5)
      expect(dummy_class.new.disabled_services(node, :python).length).to eq(2)

      expect(dummy_class.new.enabled_services(node, :php).length).to eq(13)
      expect(dummy_class.new.disabled_services(node, :php).length).to eq(1)
    end
  end

  describe '#crons' do
    it 'should return the right crons' do
      node.set[:scalr_server][:cron][:enable] = true
      node.set[:scalr_server][:cron][:disable] = []
      expect(dummy_class.new.enabled_crons(node).length).to eq(1)
      expect(dummy_class.new.disabled_crons(node).length).to eq(18)
    end

    it 'should support false' do
      node.set[:scalr_server][:cron][:enable] = false
      node.set[:scalr_server][:cron][:disable] = []
      expect(dummy_class.new.enabled_crons(node).length).to eq(0)
      expect(dummy_class.new.disabled_crons(node).length).to eq(19)
    end
  end

  describe '#enable_module?' do
    it 'should always enable some modules' do
      %w{supervisor dirs users sysctl logrotate crond}.each do |mod|
        expect(dummy_class.new.enable_module?(node, mod.to_sym)).to be_truthy
        expect(dummy_class.new.enable_module?(node, mod)).to be_truthy
      end
    end

    it 'should special-case app' do
      # Check with all modules off
      node.set[:scalr_server][:enable_all] = false
      node.set[:scalr_server][:proxy][:enable] = true
      %w{web rrd cron service}.each do |mod|
        node.set[:scalr_server][mod][:enable] = false
      end
      expect(dummy_class.new.enable_module?(node, :app)).to eq(false)

      # Check them one by one
      %w{web rrd cron service}.each do |mod|
        node.set[:scalr_server][mod][:enable] = true
        expect(dummy_class.new.enable_module?(node, :app)).to eq(true)
        node.set[:scalr_server][mod][:enable] = false
      end

      # Check everything reset properly
      expect(dummy_class.new.enable_module?(node, :app)).to eq(false)

      # Check with all modules implicitly on
      node.set[:scalr_server][:enable_all] = true
      expect(dummy_class.new.enable_module?(node, :app)).to eq(true)
    end

    it 'should special-case httpd' do
      %w{web proxy}.each do |mod|
        node.set[:scalr_server][mod][:enable] = true
        expect(dummy_class.new.enable_module?(node, :httpd)).to eq(true)
        node.set[:scalr_server][mod][:enable] = false
      end

      node.set[:scalr_server][:enable_all] = false
      expect(dummy_class.new.enable_module?(node, :httpd)).to eq(false)

      node.set[:scalr_server][:enable_all] = true
      expect(dummy_class.new.enable_module?(node, :httpd)).to eq(true)
    end

    it 'should work for other modules' do
      node.set[:scalr_server][:enable_all] = false
      node.set[:scalr_server][:mysql][:enable] = true
      expect(dummy_class.new.enable_module?(node, 'mysql')).to eq(true)

      node.set[:scalr_server][:mysql][:enable] = false
      expect(dummy_class.new.enable_module?(node, 'mysql')).to eq(false)

      node.set[:scalr_server][:enable_all] = true
      expect(dummy_class.new.enable_module?(node, 'mysql')).to eq(true)
    end
  end

  describe '#memcached_servers' do

    it 'should return Memcached Servers when it\'s the only thing set' do
      servers = %w{mc-1:123 mc-2:456}
      node.set[:scalr_server][:app][:memcached_servers] = servers
      expect(dummy_class.new.memcached_servers(node)).to eq(servers)
    end

    it 'should return the legacy setting when they are set' do
      node.set[:scalr_server][:app][:memcached_servers] = %w{mc-1:123 mc2-456}
      node.set[:scalr_server][:app][:memcached_host] = 'mc'
      node.set[:scalr_server][:app][:memcached_port] = 11211

      expect(dummy_class.new.memcached_servers(node)).to eq(%w{mc:11211})
    end
  end

  describe '#graphics_scheme' do
    it 'should default to the endpoint_scheme' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'https'
      expect(dummy_class.new.graphics_scheme(node)).to eq('https')
    end

    it 'should respect the override' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'https'
      node.set[:scalr_server][:routing][:graphics_scheme] = 'http'
      expect(dummy_class.new.graphics_scheme(node)).to eq('http')
    end
  end

  describe '#graphics_host' do
    it 'should default to the endpoint_scheme' do
      node.set[:scalr_server][:routing][:endpoint_host] = 'example.com'
      expect(dummy_class.new.graphics_host(node)).to eq('example.com')
    end

    it 'should respect the override' do
      node.set[:scalr_server][:routing][:endpoint_host] = 'example.com'
      node.set[:scalr_server][:routing][:graphics_host] = 'graphics.com'
      expect(dummy_class.new.graphics_host(node)).to eq('graphics.com')
    end
  end

  describe '#plotter_scheme' do
    it 'should default to the endpoint_scheme' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'https'
      expect(dummy_class.new.plotter_scheme(node)).to eq('https')
    end

    it 'should respect the override' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'https'
      node.set[:scalr_server][:routing][:plotter_scheme] = 'http'
      expect(dummy_class.new.plotter_scheme(node)).to eq('http')
    end
  end

  describe '#plotter_host' do
    it 'should default to the endpoint_scheme' do
      node.set[:scalr_server][:routing][:endpoint_host] = 'example.com'
      expect(dummy_class.new.plotter_host(node)).to eq('example.com')
    end

    it 'should respect the override' do
      node.set[:scalr_server][:routing][:endpoint_host] = 'example.com'
      node.set[:scalr_server][:routing][:plotter_host] = 'plotter.com'
      expect(dummy_class.new.plotter_host(node)).to eq('plotter.com')
    end
  end

  describe '#plotter_port' do
    it 'should default to 443 for https' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'https'
      expect(dummy_class.new.plotter_port(node)).to eq(443)
    end

    it 'should default to 80 for http' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'http'
      expect(dummy_class.new.plotter_port(node)).to eq(80)
    end

    it 'should respect the override' do
      node.set[:scalr_server][:routing][:endpoint_scheme] = 'https'
      node.set[:scalr_server][:routing][:plotter_port] = 8000
      expect(dummy_class.new.plotter_port(node)).to eq(8000)
    end
  end

  describe '#session_cookie_timeout' do
    it 'should use session_cookie_lifetime if set'  do
      node.set[:scalr_server][:app][:session_cookie_lifetime] = 10
      node.set[:scalr_server][:app][:session_cookie_timeout] = 20
      expect(dummy_class.new.session_cookie_timeout(node)).to eq(10)
    end

    it 'should consider 0 to be set'  do
      node.set[:scalr_server][:app][:session_cookie_lifetime] = 0
      node.set[:scalr_server][:app][:session_cookie_timeout] = 20
      expect(dummy_class.new.session_cookie_timeout(node)).to eq(0)
    end

    it 'should use session_cookie_timeout otherwise' do
      node.set[:scalr_server][:app][:session_cookie_lifetime] = nil
      node.set[:scalr_server][:app][:session_cookie_timeout] = 0
      expect(dummy_class.new.session_cookie_timeout(node)).to eq(0)
    end
  end

  describe '#session_soft_timeout' do
    it 'should return the session soft timeout' do
      node.set[:scalr_server][:app][:session_soft_timeout] = 10
      expect(dummy_class.new.session_soft_timeout(node)).to eq(10)
    end
  end

end
