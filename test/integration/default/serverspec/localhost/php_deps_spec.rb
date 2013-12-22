require 'spec_helper'

php = "/usr/local/bin/php"

%W{posix_getpid pcntl_fork shm_attach msg_get_queue snmpget ssh2_exec
   curl_exec socket_create yaml_parse simplexml_load_string mysqli_connect
   gettext mcrypt_encrypt hash json_encode openssl_verify}.each do |fn|
  describe command("#{php} -r \"echo function_exists('#{fn}');\"") do
    it { should return_stdout '1' }
  end
end

%W{HTTPRequest DOMDocument SoapClient}.each do |cls|
  describe command("#{php} -r \"echo class_exists('#{cls}');\"") do
    it { should return_stdout '1' }
  end
end
