require 'fastlane/action'
require 'fastlane_core'
require 'redcarpet'

require_relative '../helper/nordalp_app_publish_helper'

module Fastlane
  module Actions
    # Fastlane Plugin action class
    class NordalpAppPublishAction < Action
      # rubocop:disable Require/MissingRequireStatement
      def self.run(params)
        UI.message("Upload to #{params[:url]} using #{params[:token]}")
        changelog = Helper::NordalpAppPublishHelper.read_first_changelog_entry('CHANGELOG.md')
        UI.message("Changelog for #{changelog[:version]} @ #{changelog[:date]}")

        jsons = lane_context[SharedValues::GRADLE_ALL_OUTPUT_JSON_OUTPUT_PATHS]
        links = lane_context[:S3_ALL_FILE_URL]
        if jsons.length == links.length
          # Markdown renderer to convert changelog to HTML
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

          jsons.each_with_index do |element, index|
            # Read app data from json-output file
            json_string = File.read(element)
            data_hash = JSON.parse(json_string)
            application_id = data_hash['applicationId']
            version_code = data_hash['elements'][0]['versionCode']
            version_name = data_hash['elements'][0]['versionName']

            # Send data to CMS
            # The CMS will discard any submissions with an application_id that does not yet have a record
            post_data = {
              changelog: {
                version: changelog[:version],
                date: changelog[:date],
                # The Changelog expects the 
                text: markdown
                        .render(changelog[:text])
                        .gsub('<h3>', '<h5>')
                        .gsub('</h3>', '</h5>')
              },
              application_id: application_id,
              link: links[index],
              version_code: version_code,
              version_name: version_name
            }
            result = Helper::NordalpAppPublishHelper.post_app(params[:url], params[:token], post_data)
            UI.message("Sent #{application_id} with result #{result}")
          end
        else
          UI.message('Number of items not equal in json and link arrays!')
        end
      end
      # rubocop:enable Require/MissingRequireStatement

      def self.description
        'Publish an app update to Nordalp website'
      end

      def self.authors
        ['ov3rk1ll']
      end

      def self.return_value
        # Optional
      end

      def self.details
        # Optional:
        ''
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: 'NORDALP_APP_PUBLISH_TOKEN',
                                       description: 'Access token for CMS',
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: 'NORDALP_APP_PUBLISH_URL',
                                       description: 'URL for CMS flow',
                                       optional: true,
                                       default_value: 'https://cms.nordalp.de/flows/trigger/d6c99c78-63cf-4701-a297-aeee079ad8da',
                                       type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
