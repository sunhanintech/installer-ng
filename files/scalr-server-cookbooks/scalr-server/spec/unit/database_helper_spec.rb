require 'spec_helper'

describe Scalr::VersionHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::DatabaseHelper } }

  describe 'db_params' do
    it 'should work' do
      node.set[:scalr_server][:mysql][:root_password] = 'rootpass'

      node.set[:scalr_server][:mysql][:host] = 'localhost'
      node.set[:scalr_server][:mysql][:port] = 3306
      node.set[:scalr_server][:mysql][:scalr_user] = 'user'
      node.set[:scalr_server][:mysql][:scalr_password] = 'scalrpass'
      node.set[:scalr_server][:mysql][:scalr_dbname] = 'scalr'
      node.set[:scalr_server][:mysql][:analytics_dbname] = 'analytics'

      expect(dummy_class.new.mysql_root_params node).to eq({:username => 'root', :password => 'rootpass', :host => 'localhost', :port => 3306})
      expect(dummy_class.new.mysql_user_params node).to eq({:username => 'user', :password => 'scalrpass', :host => 'localhost', :port => 3306})
    end
  end

end
