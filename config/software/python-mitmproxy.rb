name 'python-mitmproxy'
default_version '2796fc26a4a8be5bd71925637d16cba72f516ccf'

dependency "python3"
dependency "pip"

license url: 'https://raw.githubusercontent.com/Scalr/mitmproxy/master/LICENSE'

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['OPENSSL_DIR'] = "#{install_dir}/embedded"

  command "#{install_dir}/embedded/bin/pip3 install https://github.com/Scalr/mitmproxy/archive/#{version}.tar.gz#egg=mitmproxy", env: env
end
