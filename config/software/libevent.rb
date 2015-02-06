name 'libevent'
default_version '2.0.22-stable'

source :url => "http://downloads.sourceforge.net/levent/libevent-#{version}.tar.gz"

version '2.0.22-stable' do
  source :md5 => 'c4c56f986aa985677ca1db89630a2e11'
end

dependency 'openssl'

relative_path "libevent-#{version}"


build do
  env = with_standard_compiler_flags(with_embedded_path)

  cmd = [
      './configure',
      "--prefix=#{install_dir}/embedded",
      "--with-openssl=#{install_dir}/embedded",
      '--disable-static',
  ]

  command cmd.join(' '), env: env
  make env: env
  make 'install', env: env
end
