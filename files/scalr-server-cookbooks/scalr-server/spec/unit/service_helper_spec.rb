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
    it 'should always enable supervisor' do
      expect(dummy_class.new.enable_module?(node, :supervisor)).to eq(true)
      expect(dummy_class.new.enable_module?(node, 'supervisor')).to eq(true)
    end

    it 'should special-case app' do
      # Check with all modules off
      node.set[:scalr_server][:enable_all] = false
      %w{web proxy rrd cron service}.each do |mod|
        node.set[:scalr_server][mod][:enable] = false
      end
      expect(dummy_class.new.enable_module?(node, :app)).to eq(false)

      # Check them one by one
      %w{web proxy rrd cron service}.each do |mod|
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

  describe '#memcached_enable_sasl?' do
    it 'should be enabled by the override' do
      node.set[:scalr_server][:memcached][:enable_sasl] = true
      node.set[:scalr_server][:memcached][:bind_host] = '127.0.0.1'
      expect(dummy_class.new.memcached_enable_sasl?(node)).to be_truthy
    end

    it 'should be disabled by the override' do
      node.set[:scalr_server][:memcached][:enable_sasl] = false
      node.set[:scalr_server][:memcached][:bind_host] = '0.0.0.0'
      expect(dummy_class.new.memcached_enable_sasl?(node)).to be_falsey
    end

    it 'should be enabled if there is no override and Memcached is binding on a public IP' do
      node.set[:scalr_server][:memcached][:enable_sasl] = nil
      node.set[:scalr_server][:memcached][:bind_host] = '0.0.0.0'
      expect(dummy_class.new.memcached_enable_sasl?(node)).to be_truthy
    end

    it 'should be disabled if there is no override and Memcached is binding on 127.0.0.1' do
      node.set[:scalr_server][:memcached][:enable_sasl] = nil
      node.set[:scalr_server][:memcached][:bind_host] = '127.0.0.1'
      expect(dummy_class.new.memcached_enable_sasl?(node)).to be_falsey
    end


  end

end
