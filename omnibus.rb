use_s3_caching true
s3_access_key  ENV['AWS_ACCESS_KEY_ID']
s3_secret_key  ENV['AWS_SECRET_ACCESS_KEY']
s3_bucket      'installer-omnibus-cache'

base_dir      ENV.fetch('OMNIBUS_BASE_DIR', '/var/cache/omnibus')
