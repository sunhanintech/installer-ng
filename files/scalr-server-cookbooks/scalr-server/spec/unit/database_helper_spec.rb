require 'spec_helper'

describe Scalr::ServiceHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::DatabaseHelper } }

  describe 'db_params' do
    it 'should work' do
      node.set[:scalr_server][:install_root] = '/opt/scalr-server'

      node.set[:scalr_server][:mysql][:root_password] = 'rootpass'

      node.set[:scalr_server][:app][:mysql_scalr_host] = '192.168.1.10'
      node.set[:scalr_server][:app][:mysql_scalr_port] = 13306

      node.set[:scalr_server][:app][:mysql_analytics_host] = '192.168.1.20'
      node.set[:scalr_server][:app][:mysql_analytics_port] = 23306


      node.set[:scalr_server][:mysql][:scalr_user] = 'user'
      node.set[:scalr_server][:mysql][:scalr_password] = 'scalrpass'
      node.set[:scalr_server][:mysql][:scalr_dbname] = 'scalr'
      node.set[:scalr_server][:mysql][:analytics_dbname] = 'analytics'

      expect(dummy_class.new.mysql_admin_params node).to eq({:username => 'root', :password => 'rootpass', :socket => '/opt/scalr-server/var/run/mysql/mysql.sock'})
      expect(dummy_class.new.mysql_scalr_params node).to eq({:username => 'user', :password => 'scalrpass', :host => '192.168.1.10', :port => 13306})
      expect(dummy_class.new.mysql_analytics_params node).to eq({:username => 'user', :password => 'scalrpass', :host => '192.168.1.20', :port => 23306})
    end
  end

end
