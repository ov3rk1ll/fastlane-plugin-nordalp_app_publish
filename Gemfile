source('https://rubygems.org')

# Provides a consistent environment for Ruby projects by tracking and installing exact gem versions.
gem 'bundler'
# Automation tool for mobile developers.
gem 'fastlane', '>= 2.228.0'

gemspec

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)


