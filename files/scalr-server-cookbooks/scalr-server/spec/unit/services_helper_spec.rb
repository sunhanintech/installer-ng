require 'spec_helper'

describe Scalr::ServicesHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ServicesHelper } }

  describe '#services' do
    it 'should return the right services' do
      node.set[:scalr_server][:worker][:enable] = true

      enabled_services = dummy_class.new.enabled_services(node).collect {|service| service[:service_name]}
      expect(enabled_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})

      a_poller = dummy_class.new.enabled_services(node).select {|service| service[:service_name] == 'analytics_poller'}.fetch(0)
      expect(a_poller[:run][:cron]).to be_nil
    end

    it 'should support false' do
      node.set[:scalr_server][:worker][:enable] = false
      expect(dummy_class.new.enabled_services(node).length).to eq(0)
    end

    it 'should support filtered services' do
      node.set[:scalr_server][:worker][:enable] = %w{plotter poller}
      expect(dummy_class.new.enabled_services(node).length).to eq(2)
    end
  end

  describe '#enabled_crons' do
    it 'should return the right crons' do
      node.set[:scalr_server][:cron][:enable] = true
      expect(dummy_class.new.enabled_crons(node).length).to equal(19)
    end

    it 'should support false' do
      node.set[:scalr_server][:cron][:enable] = false
      expect(dummy_class.new.enabled_crons(node).length).to equal(0)
    end

    it 'should support filtered crons' do
      node.set[:scalr_server][:cron][:enable] = %w{Scheduler RotateLogs}
      expect(dummy_class.new.enabled_crons(node).length).to equal(2)
    end
  end

  describe '#apache_serve_graphics' do
    it 'should return true when everything is enabled' do
      node.set[:scalr_server][:rrd][:enable] = true
      node.set[:scalr_server][:worker][:enable] = true
      expect(dummy_class.new.apache_serve_graphics(node)).to be_truthy
    end

    it 'should return false when rrd is missing' do
      node.set[:scalr_server][:rrd][:enable] = false
      node.set[:scalr_server][:worker][:enable] = true
      expect(dummy_class.new.apache_serve_graphics(node)).to be_falsey
    end

    it 'should return false when the plotter is missing' do
      node.set[:scalr_server][:rrd][:enable] = true
      node.set[:scalr_server][:worker][:enable] = %w{poller analytics_processor}
      expect(dummy_class.new.apache_serve_graphics(node)).to be_falsey
    end

    it 'should return false when the poller is missing' do
      node.set[:scalr_server][:rrd][:enable] = true
      node.set[:scalr_server][:worker][:enable] = %w{plotter analytics_poller}
      expect(dummy_class.new.apache_serve_graphics(node)).to be_falsey
    end
  end
end