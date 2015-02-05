require 'spec_helper'

describe Scalr::ServiceHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ServiceHelper } }

  describe '#services' do
    it 'should return the right services' do
      node.set[:scalr_server][:service][:enable] = true

      python_services = dummy_class.new.enabled_services(node, :python).collect {|service| service[:name]}
      expect(python_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})

      php_services = dummy_class.new.enabled_services(node, :php).collect {|service| service[:name]}
      expect(php_services.length).to equal(13)
    end

    it 'should support false' do
      node.set[:scalr_server][:service][:enable] = false
      expect(dummy_class.new.enabled_services(node, :python).length).to eq(0)
      expect(dummy_class.new.disabled_services(node, :python).length).to eq(7)
    end

    it 'should support filtered services' do
      node.set[:scalr_server][:service][:enable] = %w{plotter poller server_terminate images_builder scalarizr_messaging}
      expect(dummy_class.new.enabled_services(node, :python).length).to eq(2)
      expect(dummy_class.new.disabled_services(node, :python).length).to eq(5)

      expect(dummy_class.new.enabled_services(node, :php).length).to eq(3)
      expect(dummy_class.new.disabled_services(node, :php).length).to eq(10)
    end
  end

  describe '#crons' do
    it 'should return the right crons' do
      node.set[:scalr_server][:cron][:enable] = true
      expect(dummy_class.new.enabled_crons(node).length).to equal(1)
      expect(dummy_class.new.enabled_crons(node)[0][:name]).to eq('DNSManagerPoll')
      expect(dummy_class.new.disabled_crons(node).length).to equal(18)
    end

    it 'should support false' do
      node.set[:scalr_server][:cron][:enable] = false
      expect(dummy_class.new.enabled_crons(node).length).to equal(0)
      expect(dummy_class.new.disabled_crons(node).length).to equal(19)
    end

    it 'should support filters' do
      node.set[:scalr_server][:cron][:enable] = []
      expect(dummy_class.new.enabled_crons(node).length).to equal(0)
      expect(dummy_class.new.disabled_crons(node).length).to equal(19)
    end

    it 'should support filters' do
      node.set[:scalr_server][:cron][:enable] = %w(DNSManagerPoll RotateLogs)
      expect(dummy_class.new.enabled_crons(node).length).to equal(1)
      expect(dummy_class.new.disabled_crons(node).length).to equal(18)
    end
  end
end
