name 'dcron'
default_version '4.5'

source url: "http://www.jimpryor.net/linux/releases/dcron-#{version}.tar.gz",
       md5: '078833f3281f96944fc30392b1888326'

relative_path "#{name}-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # The list of arguments to pass to make
  args = "PREFIX='#{install_dir}/embedded'" \
         " SCRONTABS='#{install_dir}/etc/cron/cron.d'" \
         " CRONTABS='#{install_dir}/var/spool/cron/crontabs'" \
         " CRONSTAMPS='#{install_dir}/var/spool/cron/cronstamps'" \
         ' CRONTAB_GROUP=root'

  make "#{args}", env: env
  make 'install', env: env
end
