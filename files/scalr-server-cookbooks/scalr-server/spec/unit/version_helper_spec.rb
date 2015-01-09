require 'spec_helper'

describe Scalr::VersionHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::VersionHelper } }

  describe '#has_scalrpy2?' do
    it 'should be false on Scalr 5.0' do
      node.set[:scalr][:package][:version] = '5.0.0'
      expect(dummy_class.new.has_scalrpy2? node).to be_falsey
    end

    it 'should be true on Scalr 5.1' do
      node.set[:scalr][:package][:version] = '5.1'
      expect(dummy_class.new.has_scalrpy2? node).to be_truthy
    end

    it 'should be true on Scalr 5.1.1' do
      node.set[:scalr][:package][:version] = '5.1.1'
      expect(dummy_class.new.has_scalrpy2? node).to be_truthy
    end

    it 'should be true on Scalr 5.2' do
      node.set[:scalr][:package][:version] = '5.2'
      expect(dummy_class.new.has_scalrpy2? node).to be_truthy
    end
  end

  describe '#services' do
    it 'should return the right services on Scalr 4.5' do
      node.set[:scalr][:package][:version] = '4.5'

      enabled_services = dummy_class.new.enabled_services(node).collect {|service| service[:service_name]}
      expect(enabled_services).to eq(%w{msgsender dbqueue plotter poller})
    end

    it 'should return the right services on Scalr 5.0' do
      node.set[:scalr][:package][:version] = '5.0'

      enabled_services = dummy_class.new.enabled_services(node).collect {|service| service[:service_name]}
      expect(enabled_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})

      a_poller = dummy_class.new.enabled_services(node).select {|service| service[:service_name] == 'analytics_poller'}.fetch(0)
      expect(a_poller[:run][:daemon]).to be_nil
    end

    it 'should return the right services on Scalr 5.1' do
      node.set[:scalr][:package][:version] = '5.1'

      enabled_services = dummy_class.new.enabled_services(node).collect {|service| service[:service_name]}
      expect(enabled_services).to eq(%w{msgsender dbqueue plotter poller szrupdater analytics_poller analytics_processor})

      a_poller = dummy_class.new.enabled_services(node).select {|service| service[:service_name] == 'analytics_poller'}.fetch(0)
      expect(a_poller[:run][:cron]).to be_nil
    end
  end

  describe '#crons' do
    it 'should return the right crons on Scalr 4.5' do
      node.set[:scalr][:package][:version] = '4.5'
      expect(dummy_class.new.enabled_crons(node).length).to equal(14)  # 13 constant + 1 for messaging
    end

    it 'should return the right crons on Scalr 5.0' do
      node.set[:scalr][:package][:version] = '5.0'
      expect(dummy_class.new.enabled_crons(node).length).to equal(23)  # 13 constant + 2 for CA + 8 for messaging
    end

    it 'should return the right crons on Scalr 5.1' do
      node.set[:scalr][:package][:version] = '5.1'
      expect(dummy_class.new.enabled_crons(node).length).to equal(23)  # Same as above
    end

    it 'should return the right crons on Scalr 5.1.1' do
      node.set[:scalr][:package][:version] = '5.1.1'
      expect(dummy_class.new.enabled_crons(node).length).to equal(19)  # 13 constant + 2 for CA + 4 for messaging
    end
  end

  describe '#has_migrations?' do
    it 'should return the right information on Scalr 4.5' do
      node.set[:scalr][:package][:version] = '4.5'
      expect(dummy_class.new.has_migrations?(node)).to be_falsey
    end

    it 'should return the right information on Scalr 5.0' do
      node.set[:scalr][:package][:version] = '5.0'
      expect(dummy_class.new.has_migrations?(node)).to be_truthy
    end

    it 'should return the right information on Scalr 5.1' do
      node.set[:scalr][:package][:version] = '5.1'
      expect(dummy_class.new.has_migrations?(node)).to be_truthy
    end
  end

  describe '#has_cost_analytics?' do
    it 'should return the right information on Scalr 4.5' do
      node.set[:scalr][:package][:version] = '4.5'
      expect(dummy_class.new.has_cost_analytics?(node)).to be_falsey
    end

    it 'should return the right information on Scalr 5.0' do
      node.set[:scalr][:package][:version] = '5.0'
      expect(dummy_class.new.has_cost_analytics?(node)).to be_truthy
    end

    it 'should return the right information on Scalr 5.1' do
      node.set[:scalr][:package][:version] = '5.1'
      expect(dummy_class.new.has_cost_analytics?(node)).to be_truthy
    end
  end

end