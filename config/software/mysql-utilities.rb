name 'mysql-utilities'
default_version '1.5.3'

source url: "http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-#{version}.zip"

version '1.5.3' do
  source md5: 'e93ff4acf6a8b64b09af86a4829d0d6b'
end

relative_path "mysql-utilities-#{version}"

dependency 'python'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/python setup.py install --skip-profile", env: env
end
