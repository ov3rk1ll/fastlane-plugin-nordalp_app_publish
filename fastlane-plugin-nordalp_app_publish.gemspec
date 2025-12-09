lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/nordalp_app_publish/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-nordalp_app_publish'
  spec.version       = Fastlane::NordalpAppPublish::VERSION
  spec.author        = 'ov3rk1ll'
  spec.email         = 'overkillerror@gmail.com'

  spec.summary       = 'Publish a app update to Nordalp website'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-nordalp_app_publish"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
  spec.add_dependency "httparty", "~> 0.23.2"
  spec.add_dependency "redcarpet", "~> 3.6.1"
end
