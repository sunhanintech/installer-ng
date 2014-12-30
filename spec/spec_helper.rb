require 'chefspec'
# require 'chefspec/berkshelf'  # We don't have tests that depend on this for now.

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

