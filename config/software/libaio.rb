name 'libaio'
default_version '0.3.110'

# Note: we are getting this from Debian, because we trust Debian as a source, but the package has nothing
# Debian-specific about it.
source url: "http://ftp.debian.org/debian/pool/main/liba/libaio/libaio_#{version}.orig.tar.gz"


version '0.3.110' do
  source md5: '2a35602e43778383e2f4907a4ca39ab8'
end

relative_path "libaio-#{version}"

license path: 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  make "-j #{workers} prefix=#{install_dir}/embedded install", env: env
end
