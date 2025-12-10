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

        apks = lane_context[SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS]
        jsons = lane_context[SharedValues::GRADLE_ALL_OUTPUT_JSON_OUTPUT_PATHS]
        links = lane_context[:S3_ALL_FILE_URL]
        if apks.length == jsons.length && apks.length == links.length
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
          UI.message("Sending #{links.length} version(s) to CMS")
          jsons.each_with_index do |element, index|
            json_string = File.read(element)
            data_hash = JSON.parse(json_string)
            application_id = data_hash['applicationId']
            version_code = data_hash['elements'][0]['versionCode']
            version_name = data_hash['elements'][0]['versionName']
            UI.message("Use #{links[index]} for #{application_id}")
            result = Helper::NordalpAppPublishHelper.post_app(params[:url], params[:token], {
                                                                changelog: {
                                                                  version: changelog[:version],
                                                                  date: changelog[:date],
                                                                  text: markdown.render(changelog[:text]).gsub('<h3>', '<h5>').gsub(
                                                                    '</h3>', '</h5>'
                                                                  )
                                                                },
                                                                application_id: application_id,
                                                                link: links[index],
                                                                version_code: version_code,
                                                                version_name: version_name
                                                              })
            UI.message("Result #{result}")
          end
        else
          UI.message('Number of items not equal in 3 arrays!')
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
