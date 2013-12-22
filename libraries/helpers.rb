def php_enable_mod(mod)
  case node['platform_family']
  when 'debian'
    success = system("php5enmod #{mod}")
    if !success
      Chef::Log.fatal!("Failed to enable php5 mod: #{mod}")
    else
      Chef::Log.info("Enabled php5 mod: #{mod}")
    end
  end
end
