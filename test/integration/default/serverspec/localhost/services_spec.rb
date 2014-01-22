require 'spec_helper'

describe 'Scalr Daemon Server' do

  %w{msgsender dbqueue poller plotter rrdcached}.each do |svc|
    it "should be running #{svc}" do
      expect(service svc).to be_running
    end
  end
end
