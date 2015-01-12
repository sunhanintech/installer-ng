name 'cronie'
default_version '1.4.12'

source url: "https://fedorahosted.org/releases/c/r/cronie/cronie-#{version}.tar.gz",
       md5: '199db91e514a4d75e3222d69874b132f'

relative_path "cronie-#{version}"
#TODO - selinux?

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command 'aclocal', env: env
  command 'automake --add-missing', env: env
  command 'autoreconf', env: env
  command "./configure --prefix=#{install_dir}/embedded" \
          ' --with-inotify' \
          ' --enable-anacron', env: env
  make env: env
  make 'install', env: env
end
