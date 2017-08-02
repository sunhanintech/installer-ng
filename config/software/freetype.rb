# Actual freetype installation.
name 'freetype'
default_version '2.7.1'

source url: "http://download.savannah.gnu.org/releases/freetype/freetype-#{version}.tar.bz2"

version '2.5.5' do
  source md5: '2a7a314927011d5030903179cf183be0'
end

version '2.7.1' do
  source md5: 'b3230110e0cab777e0df7631837ac36e'
end

dependency 'libpng'
dependency 'bzip2'
dependency 'zlib'
dependency 'harfbuzz'

relative_path "freetype-#{version}"

license 'FTL'
license_file 'docs/FTL.TXT'
skip_transitive_dependency_licensing true



build do
  env = with_standard_compiler_flags(with_embedded_path)

  # It seems that pkg-config fails to find harfbuzz on CentOS (though it does find it when run from the CLI).
  env['HARFBUZZ_CFLAGS'] = "-I#{install_dir}/embedded/include/harfbuzz -lbz2"
  env['HARFBUZZ_LIBS'] = "-L#{install_dir}/lib -lharfbuzz"

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --with-zlib=yes' \
          ' --with-bzip2=yes' \
          ' --with-png=yes' \
          ' --with-harfbuzz=yes', env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
