name 'python-m2crypto'
default_version '0.22.3'

source url: "https://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-#{version}.tar.gz",
       md5: '573f21aaac7d5c9549798e72ffcefedd'

relative_path "M2Crypto-#{version}"

dependency 'python'
dependency 'openssl'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/python setup.py build build_ext --openssl=#{install_dir}/embedded", env: env
  command "#{install_dir}/embedded/bin/python setup.py install build_ext --openssl=#{install_dir}/embedded", env: env
end
