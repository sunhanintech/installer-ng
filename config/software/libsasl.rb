name 'libsasl'
default_version '2.1.26'

source url: "ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-.#{version}.tar.gz"

version '2.1.26' do
  source md5: 'a7f4e5e559a0e37b3ffc438c9456e425'
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
