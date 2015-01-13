require 'spec_helper'

describe Scalr::ServicesHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ServicesHelper } }

  describe '#services' do
    it 'should return the right services for Scalr 5.1.1' do
      enabled_services = dummy_class.new.enabled_services(node).collect {|service| service[:service_name]}
      expect(enabled_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})

      a_poller = dummy_class.new.enabled_services(node).select {|service| service[:service_name] == 'analytics_poller'}.fetch(0)
      expect(a_poller[:run][:cron]).to be_nil
    end
  end

  describe '#crons' do
    it 'should return the right crons for Scalr 5.1.1' do
      expect(dummy_class.new.enabled_crons(node).length).to equal(19)  # 13 constant + 2 for CA + 4 for messaging
    end
  end
end