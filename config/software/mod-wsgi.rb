name 'mod-wsgi'
default_version '4.5.15'

source url: "https://codeload.github.com/GrahamDumpleton/mod_wsgi/tar.gz/#{version}"

version '4.5.15' do
    source md5: 'abebfc30a9d161ded03c458993f6be3e'
end

dependency 'httpd'

relative_path "mod_wsgi-#{version}"

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          " --with-apxs=#{install_dir}/embedded/bin/apxs" \
          " --with-python=#{install_dir}/embedded/bin/python", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
