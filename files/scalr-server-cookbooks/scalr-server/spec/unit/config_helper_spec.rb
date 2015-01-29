require 'spec_helper'
require 'yaml'

describe Scalr::ConfigHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::ConfigHelper } }

  describe 'helper' do
    it 'should work' do
      node.set[:scalr_server][:mysql][:root_password] = 'rootpass'
      node.set[:scalr_server][:mysql][:scalr_user] = 'user'
      node.set[:scalr_server][:mysql][:scalr_password] = 'scalrpass'
      node.set[:scalr_server][:mysql][:scalr_dbname] = 'scalr'
      node.set[:scalr_server][:mysql][:analytics_dbname] = 'analytics'

      node.set[:scalr_server][:app][:id] = '12345678'
      node.set[:scalr_server][:app][:ip_ranges] = %w{1.1.1.1 2.2.2.2}
      node.set[:scalr_server][:app][:email_from_address] = 'test@example.com'
      node.set[:scalr_server][:app][:email_from_name] = 'Test User'

      node.set[:scalr_server][:service][:enable] = true
      node.set[:scalr_server][:service][:plotter_bind_scheme] = 'http'
      node.set[:scalr_server][:service][:plotter_bind_host] = '0.0.0.0'
      node.set[:scalr_server][:service][:plotter_bind_port] = 8080

      node.set[:scalr_server][:routing][:mysql_host] = '127.0.0.1'
      node.set[:scalr_server][:routing][:mysql_port] = 3306

      node.set[:scalr_server][:routing][:endpoint_scheme] = 'http'
      node.set[:scalr_server][:routing][:endpoint_host] = 'test.com'

      node.set[:scalr_server][:routing][:graphics_scheme] = 'http'
      node.set[:scalr_server][:routing][:graphics_host] = 'test.com'
      node.set[:scalr_server][:routing][:graphics_path] = 'graphics'

      node.set[:scalr_server][:routing][:plotter_scheme] = 'http'
      node.set[:scalr_server][:routing][:plotter_host] = 'test.com'
      node.set[:scalr_server][:routing][:plotter_port] = 8080

      # Pretty basic test... We just assert that the config can be loaded.
      YAML.load(dummy_class.new.dump_scalr_configuration node)

      # Now, try with a non-nil override
      node.set[:scalr_server][:app][:configuration] = {}
      YAML.load(dummy_class.new.dump_scalr_configuration node)

      # Finally, check overrides work
      # noinspection RubyStringKeysInHashInspection
      node.set[:scalr_server][:app][:configuration] = {
          :scalr => {
              # Check a simple override
              :auth_mode => 'ldap',

              :connections => {
                  # Check new key
                  :ldap => {
                    :host => 'localhost',
                  },
                  # Check merge
                  :mysql => {
                      port: 1234
                  }
              },
              # Check string key
              'aws' => {
                  'ip_pool' => %w(A B C) # (using something totally absurd here intentionally)

              }
          }
      }

      d = YAML.load(dummy_class.new.dump_scalr_configuration node)

      expect(d['scalr']['auth_mode']).to eq('ldap')

      expect(d['scalr']['connections']['mysql']['host']).to eq('127.0.0.1')
      expect(d['scalr']['connections']['mysql']['port']).to eq(1234)

      expect(d['scalr']['connections']['ldap']['host']).to eq('localhost')

      expect(d['scalr']['aws']['ip_pool']).to eq(%w{A B C })
      expect(d['scalr']['aws']['security_group_name']).to eq('scalr.12345678.ip-pool')  # ??


    end
  end
end
