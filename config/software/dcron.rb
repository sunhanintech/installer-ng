name 'dcron'
default_version '4.5'

source url: "http://www.jimpryor.net/linux/releases/dcron-#{version}.tar.gz",
       md5: '078833f3281f96944fc30392b1888326'

relative_path "#{name}-#{version}"

license 'GPL-3.0'
license_file 'https://www.gnu.org/licenses/gpl-3.0.txt'
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # The list of arguments to pass to make
  args = "PREFIX='#{install_dir}/embedded'" \
         " SCRONTABS='#{install_dir}/etc/crond/cron.d'" \
         " CRONTABS='#{install_dir}/var/spool/crond/crontabs'" \
         " CRONSTAMPS='#{install_dir}/var/spool/crond/cronstamps'" \
         ' CRONTAB_GROUP=root'

  make "-j #{workers} #{args}", env: env
  make 'install', env: env
end
