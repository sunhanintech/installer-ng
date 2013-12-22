require 'spec_helper'

php = "/usr/bin/php"

%W{socket_create gettext simplexml_load_string mcrypt_encrypt mhash_count pcntl_fork posix_getpid
   mysqli_connect simplexml_load_string is_soap_fault snmpget curl_exec msg_send shm_attach sem_get
   ssh2_exec yaml_parse json_encode openssl_verify}.each do |fn|
  describe command("#{php} -r \"echo function_exists('#{fn}');\"") do
    it { should return_stdout '1' }
  end
end
