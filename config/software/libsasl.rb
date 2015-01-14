name 'libsasl'
default_version '2.1.26'

source url: "http://ftp.debian.org/debian/pool/main/c/cyrus-sasl2/cyrus-sasl2_#{version}.dfsg1.orig.tar.gz"

version '2.1.26' do
  source md5: '45fc09469ca059df56d64acfe06a940d'
end

relative_path "cyrus-sasl-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --disable-gssapi', env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
