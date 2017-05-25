name 'mysql-utilities'
default_version '1.6.4'

source url: "http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-#{version}.zip"

version '1.5.3' do
  source md5: 'e93ff4acf6a8b64b09af86a4829d0d6b'
end

version '1.6.4' do
  source md5: '74c1e2a16abae2508fd30baf9ef3e58c'
end

dependency 'python'

relative_path "mysql-utilities-#{version}"

license path: 'LICENSE.txt'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/python setup.py install --skip-profile", env: env
end
