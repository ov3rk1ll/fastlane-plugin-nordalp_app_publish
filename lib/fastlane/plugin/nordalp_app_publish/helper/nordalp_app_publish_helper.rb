require 'fastlane_core/ui/ui'
require 'httparty'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class NordalpAppPublishHelper
      def self.read_first_changelog_entry(filename)
        return { error: "File not found: #{filename}" } unless File.exist?(filename)

        # Read the entire file content
        content = File.read(filename)

        # Regular expression to match the first H2 version entry
        version_regex = /^##\s+(\[([^\]]+)\]\(([^)]+)\)|[^(\r?\n]+)\s*\(([^)]+)\)\s*\r?\n(.*?)(?=\r?\n## |\z)/im
        match = content.match(version_regex)

        unless match
          return { error: 'No version entries found matching the expected format (## [version](link) (date))' }
        end

        # The version name is captured in Group 2 if it's a link, or Group 1 if it's plain text.
        version_name = match[2] || match[1]&.strip
        date = match[4]
        text = match[5].strip

        {
          version: version_name,
          date: date,
          text: text
        }
      end

      def self.post_app(url_string, token_string, data_hash)
        response = HTTParty.post(
          url_string,
          {
            # HTTParty automatically converts the body (a Hash) to JSON
            # and sets the Content-Type header to application/json
            body: data_hash.to_json,
            headers: {
              'Authenticate' => token_string,
              'Content-Type' => 'application/json',
              'Accept' => 'application/json'
            }
          }
        )

        # HTTParty can optionally parse the response body if it's JSON
        {
          code: response.code,
          body: response.parsed_response # Accesses the parsed JSON response body
        }
      rescue StandardError => e
        { error: "An error occurred: #{e.message}" }
      end
    end
  end
end
