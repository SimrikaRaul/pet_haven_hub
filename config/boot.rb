ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Workaround for Windows: Stub ffi if it fails to load
begin
  require 'ffi'
rescue LoadError
  # Create a dummy FFI module to prevent load errors
  module FFI; end
end
