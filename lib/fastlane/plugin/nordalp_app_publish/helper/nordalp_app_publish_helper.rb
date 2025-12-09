require 'fastlane_core/ui/ui'
require 'httparty'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class NordalpAppPublishHelper
      # class methods that you define here become available in your action
      # as `Helper::NordalpAppPublishHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the nordalp_app_publish plugin helper!")
      end

      def self.read_first_changelog_entry(filename)
        unless File.exist?(filename)
          return { error: "File not found: #{filename}" }
        end

        # Read the entire file content
        content = File.read(filename)

        # Regular expression to match the first H2 version entry
        version_regex = /^##\s+(\[([^\]]+)\]\(([^)]+)\)|[^(\r?\n]+)\s*\(([^)]+)\)\s*\r?\n(.*?)(?=\r?\n## |\z)/im
        match = content.match(version_regex)

        if match
          # The version name is captured in Group 2 if it's a link, or Group 1 if it's plain text.
          version_name = match[2] || (match[1] ? match[1].strip : nil)
          date = match[4]
          text = match[5].strip

          return {
            version: version_name,
            date: date,
            text: text
          }
        else
          return { error: "No version entries found matching the expected format (## [version](link) (date))" }
        end
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
        return {
          code: response.code,
          body: response.parsed_response # Accesses the parsed JSON response body
        }

      rescue StandardError => e
        return { error: "An error occurred: #{e.message}" }
      end
    end
  end
end
