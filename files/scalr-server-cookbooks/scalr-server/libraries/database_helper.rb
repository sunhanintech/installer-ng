module Scalr
  module DatabaseHelper

    def mysql_base_params(node)
      {
          :host => node[:scalr_server][:routing][:mysql_host],
          :port => node[:scalr_server][:routing][:mysql_port],
      }
    end

    def mysql_root_params(node)
      mysql_base_params(node).merge({
                                        :username => 'root',
                                        :password => node[:scalr_server][:mysql][:root_password],
                                    })
    end

    def mysql_user_params(node)
      mysql_base_params(node).merge({
                                        :username => node[:scalr_server][:mysql][:scalr_user],
                                        :password => node[:scalr_server][:mysql][:scalr_password],
                                    })
    end

    def _mysql_connection(params, dbname)
      require 'mysql'
      ::Mysql.new(params[:host], params[:username], params[:password], dbname, params[:port])
    end

    def mysql_has_table?(params, dbname, tablename)
      cnt = 0
      conn = _mysql_connection(params, dbname)
      begin
        conn.query("SELECT COUNT(*) AS cnt FROM information_schema.tables WHERE table_schema='#{dbname}' AND table_name='#{tablename}'") {|res|
          res.each_hash do |row|
            cnt = row['cnt'].to_i
          end
        }
      ensure
        conn.close rescue nil
      end
      cnt > 0
    end

    def mysql_has_rows?(params, dbname, tablename)
      cnt = 0
      conn = _mysql_connection(params, dbname)
      begin
        conn.query("SELECT COUNT(*) AS cnt FROM #{tablename}") {|res|
          res.each_hash do |row|
            cnt = row['cnt'].to_i
          end
        }
      ensure
        conn.close rescue nil
      end
      cnt > 0
    end

  end
end

# Hook in
unless Chef::Recipe.ancestors.include?(Scalr::DatabaseHelper)
  Chef::Recipe.send(:include, Scalr::DatabaseHelper)
  Chef::Resource.send(:include, Scalr::DatabaseHelper)
  Chef::Provider.send(:include, Scalr::DatabaseHelper)
end
