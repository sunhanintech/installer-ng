require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'securerandom'


module ScalrServer
  extend(Mixlib::Config)

  config_strict_mode true

  default :routing, Mash.new
  default :supervisor, Mash.new
  default :mysql, Mash.new
  default :memcached, Mash.new
  default :app, Mash.new
  default :web, Mash.new
  default :proxy, Mash.new
  default :cron, Mash.new
  default :service, Mash.new
  default :rrd, Mash.new
  default :manifest, Mash.new
  default :logrotate, Mash.new
  default :enable_all, true

  class << self

    def generate_secrets(node)
      existing_secrets ||= Hash.new
      if File.exists?(secrets_file_path node)
        existing_secrets = Chef::JSONCompat.from_json(File.read(secrets_file_path node))
      end
      existing_secrets.each do |k, v|
        v.each do |pk, p|
          ScalrServer[k][pk] = p
        end
      end

      ScalrServer[:mysql][:root_password] ||= SecureRandom.hex 50
      ScalrServer[:mysql][:scalr_password] ||= SecureRandom.hex 50
      ScalrServer[:mysql][:repl_password] ||= SecureRandom.hex 12  # Password *has* to be short!!

      ScalrServer[:memcached][:password] ||= SecureRandom.hex 50

      ScalrServer[:app][:admin_password] ||= SecureRandom.hex 12
      ScalrServer[:app][:secret_key] ||= SecureRandom.base64 512
      ScalrServer[:app][:id] ||= SecureRandom.hex 4


      File.open(secrets_file_path(node), 'w') do |f|
        f.puts(Chef::JSONCompat.to_json_pretty({
          :mysql => {
            :root_password          => ScalrServer[:mysql][:root_password],
            :scalr_password         => ScalrServer[:mysql][:scalr_password],
            :repl_password          => ScalrServer[:mysql][:repl_password],
          },
          :memcached => {
              :password => ScalrServer[:memcached][:password]
          },
          :app => {
            :admin_password => ScalrServer[:app][:admin_password],
            :secret_key => ScalrServer[:app][:secret_key],
            :id => ScalrServer[:app][:id],
          }
        }))
      end
      system("chmod 0600 #{secrets_file_path node}")
    end

    def string2boolean(hash)
      hash.keys.each do |key|
        if hash[key].kind_of? Hash
          string2boolean(hash[key])
        else
          hash[key] = case hash[key]
          when "yes"
            true
          when "no"
            false
          when "1"
            true
          when "0"
            false
          when "true"
            true
          when "false"
            false
          when "on"
            true
          when "off"
            false
          when "null"
            nil
          when "nil"
            nil
          when "~"
            nil
          else
            hash[key]
          end
        end
      end
    end

    def generate_hash
      results = {:scalr_server => {} }

      # Keys that feed `scalr_server` attributes directly
      %w{routing supervisor app mysql cron rrd service web proxy memcached manifest logrotate enable_all}.each do |key|
        results[:scalr_server][key] = ScalrServer[key]
      end

      # Keys that are (also) routed somewhere else
      results[:rackspace_timezone] = {:config => {:tz => ScalrServer[:supervisor][:tz]}}

      # Make all values "safe"
      string2boolean(results)

      results
    end

    def generate_config(node)

      # Load attributes from the configuration files. Ordering matters here
      # Main attributes file. Probably where you want global settings, like 'route'
      if File.exists?(main_config_file_path node)
        ScalrServer.from_file(main_config_file_path node)
      end

      # Alternate config file. Probably where you want local settings, like what to enable
      if File.exists?(local_config_file_path node)
        ScalrServer.from_file(local_config_file_path node)
      end

      # JSON secrets, or dynamically generated
      generate_secrets node

      # Data from the manifest
      Chef::JSONCompat.from_json(File.read(manifest_file_path node)).each do |k, v|
        ScalrServer[:manifest][k] =  v
      end

      # Actual attributes generation
      generate_hash
    end

    # Helper methods

    def main_config_file_path(node)
      "#{node[:scalr_server][:config_dir]}/scalr-server.rb"
    end

    def local_config_file_path(node)
      "#{node[:scalr_server][:config_dir]}/scalr-server-local.rb"
    end

    def secrets_file_path(node)
      "#{node[:scalr_server][:config_dir]}/scalr-server-secrets.json"
    end

    def manifest_file_path(node)
      "#{node[:scalr_server][:install_root]}/embedded/scalr/manifest.json"
    end

  end
end
