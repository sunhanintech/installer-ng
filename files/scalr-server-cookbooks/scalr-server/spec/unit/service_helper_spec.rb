require 'spec_helper'

describe Scalr::ServiceHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ServiceHelper } }

  describe '#services' do
    it 'should return the right services' do
      node.set[:scalr_server][:service][:enable] = true

      enabled_services = dummy_class.new.enabled_services(node).collect {|service| service[:service_name]}
      expect(enabled_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})
    end

    it 'should support false' do
      node.set[:scalr_server][:service][:enable] = false
      expect(dummy_class.new.enabled_services(node).length).to eq(0)
      expect(dummy_class.new.disabled_services(node).length).to eq(7)
    end

    it 'should support filtered services' do
      node.set[:scalr_server][:service][:enable] = %w{plotter poller}
      expect(dummy_class.new.enabled_services(node).length).to eq(2)
      expect(dummy_class.new.disabled_services(node).length).to eq(5)
    end
  end

  describe '#crons' do
    it 'should return the right crons' do
      node.set[:scalr_server][:cron][:enable] = true
      expect(dummy_class.new.enabled_crons(node).length).to equal(19)
      expect(dummy_class.new.disabled_crons(node).length).to equal(0)
    end

    it 'should support false' do
      node.set[:scalr_server][:cron][:enable] = false
      expect(dummy_class.new.enabled_crons(node).length).to equal(0)
      expect(dummy_class.new.disabled_crons(node).length).to equal(19)
    end

    it 'should support filtered crons' do
      node.set[:scalr_server][:cron][:enable] = %w{Scheduler RotateLogs}
      expect(dummy_class.new.enabled_crons(node).length).to equal(2)
      expect(dummy_class.new.disabled_crons(node).length).to equal(17)
    end
  end

  describe '#apache' do
    it 'should return true when everything is enabled' do
      node.set[:scalr_server][:rrd][:enable] = true
      node.set[:scalr_server][:service][:enable] = true
      expect(dummy_class.new.apache_serve_graphics(node)).to be_truthy
    end

    it 'should return false when rrd is missing' do
      node.set[:scalr_server][:rrd][:enable] = false
      node.set[:scalr_server][:service][:enable] = true
      expect(dummy_class.new.apache_serve_graphics(node)).to be_falsey
    end

    it 'should return false when the plotter is missing' do
      node.set[:scalr_server][:rrd][:enable] = true
      node.set[:scalr_server][:service][:enable] = %w{poller analytics_processor}
      expect(dummy_class.new.apache_serve_graphics(node)).to be_falsey
    end

    it 'should return false when the poller is missing' do
      node.set[:scalr_server][:rrd][:enable] = true
      node.set[:scalr_server][:service][:enable] = %w{plotter analytics_poller}
      expect(dummy_class.new.apache_serve_graphics(node)).to be_falsey
    end
  end
end
