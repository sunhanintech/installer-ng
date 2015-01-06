require 'spec_helper'

describe Scalr::VersionHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::DatabaseHelper } }

  describe 'db_params' do
    it 'should work' do
      node.set[:mysql][:server_root_password] = 'rootpass'

      node.set[:scalr][:database][:host] = 'localhost'
      node.set[:scalr][:database][:port] = 3306

      node.set[:scalr][:database][:username] = 'user'
      node.set[:scalr][:database][:password] = 'scalrpass'

      node.set[:scalr][:database][:scalr_dbname] = 'scalr'
      node.set[:scalr][:database][:analytics_dbname] = 'analytics'

      expect(dummy_class.new.mysql_root_params node).to eq({:username => 'root', :password => 'rootpass', :host => 'localhost', :port => 3306})
      expect(dummy_class.new.mysql_user_params node).to eq({:username => 'user', :password => 'scalrpass', :host => 'localhost', :port => 3306})
    end
  end

end
