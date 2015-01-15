CURRENT_PATH = File.expand_path(File.dirname(__FILE__))

# Allow users to pass an overridden cookbook path
cookbook_search_path = [CURRENT_PATH]
extra_search_path = ENV.fetch('SCALR_COOKBOOK_EXTRA_SEARCH_PATH', nil)
unless extra_search_path.nil?
   cookbook_search_path.push(extra_search_path)
end

file_cache_path "#{CURRENT_PATH}/cache"
cookbook_path cookbook_search_path
verbose_logging false

# We don't actually make HTTPS requests here, so it doesn't hurt to enable verification to avoid a very
# confusing (and possibly very concerning) error message.
ssl_verify_mode :verify_peer
