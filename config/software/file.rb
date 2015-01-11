name 'file'
default_version '5.22'

source url: "ftp://ftp.astron.com/pub/file/file-#{version}.tar.gz",
       md5: '8fb13e5259fe447e02c4a37bc7225add'

relative_path "file-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
