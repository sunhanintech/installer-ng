name 'python-m2crypto'
default_version '0.22.3'

source url: "https://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-#{version}.tar.gz",
       md5: '573f21aaac7d5c9549798e72ffcefedd'

dependency 'python'
dependency 'openssl'


relative_path "M2Crypto-#{version}"

license url: 'https://raw.githubusercontent.com/M2Crypto/M2Crypto/master/LICENCE'


build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['OPENSSL_DIR'] = "#{install_dir}/embedded"

  patch source: 'accept-environ.patch'

  command "#{install_dir}/embedded/bin/pip install .", env: env
end
