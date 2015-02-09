base_dir      ENV.fetch('OMNIBUS_BASE_DIR', '/var/cache/omnibus')

if ENV.key? 'OMNIBUS_PACKAGE_DIR'
  package_dir ENV['OMNIBUS_PACKAGE_DIR']
end

# Standard flags used by Debian for compilation (dpkg-buildflags)
# Consider: https://wiki.debian.org/HardeningWalkthrough
inject_cflags '-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2'
inject_ldflags '-Wl,-Bsymbolic-functions -Wl,-z,relro'

# Note: access key, secret key, and region are needed when uploading.
use_s3_caching true
s3_bucket      'installer-omnibus-cache'
s3_region      'us-east-1'
s3_access_key  ENV.fetch('OMNIBUS_S3_ACCESS_KEY', 'access key')
s3_secret_key  ENV.fetch('OMNIBUS_S3_SECRET_KEY', 'access key')
