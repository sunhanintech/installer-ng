require 'spec_helper'


def php_cli_for_setting(php_ini, setting)
  php = "/usr/bin/php"
  command = "var_dump(ini_get('#{setting}'));"
  "#{php} --php-ini #{php_ini} -r \"#{command}\""
end


describe 'Scalr PHP Configuration' do

  it "should have the right ini settings" do

    case RSpec.configuration.os[:family]
    when "Debian", "Ubuntu"
      php_inis = %w{/etc/php5/apache2/ /etc/php5/cli/}
    when "RedHat", "CentOS"
      php_inis = %w{/etc/php.ini}
    else
      pending "This OS is not supported"
    end

    php_inis.each do |php_ini|
      expect(command php_cli_for_setting(php_ini, 'short_open_tag')).to return_stdout 'string(1) "1"'
      expect(command php_cli_for_setting(php_ini, 'disable_functions')).to return_stdout 'string(0) ""'
      expect(command php_cli_for_setting(php_ini, 'register_globals')).to return_stdout 'bool(false)'
      expect(command php_cli_for_setting(php_ini, 'date.timezone')).to return_stdout 'string(3) "UTC"'
    end

    #TODO: This doesn't actually test the Apache2 SAPI on Debian. Needs fixing. Maybe just hit the URL.

  end
end
