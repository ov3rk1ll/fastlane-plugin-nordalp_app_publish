require 'fastlane/action'

describe Fastlane::Actions::NordalpAppPublishAction do
  describe '#praseChangelog' do
    it 'with links' do
      changelog_content = <<~CHANGELOG
        # Changelog

        ## [1.12.3](https://gitlab.com/handheldgroup/maxgo-staging/app/-/compare/v1.12.2...v1.12.3) (2025-12-02)

        ### Fixes
        - fix not all Lockscreen command options working on newer Android versions#{' '}

        ## [1.12.2](https://gitlab.com/handheldgroup/maxgo-staging/app/-/compare/v1.12.1...v1.12.2) (2025-11-18)

        ### Fixes
        - support split-apk (xapk) on older Android versions

        ## [1.12.1](https://gitlab.com/handheldgroup/maxgo-staging/app/-/compare/v1.12.0...v1.12.1) (2025-11-10)

        ### Fixes
        - support byte data on intent command extra
      CHANGELOG

      filename = 'temp_changelog.md'
      File.write(filename, changelog_content)
      changelog = Fastlane::Helper::NordalpAppPublishHelper.read_first_changelog_entry(filename)

      expect(changelog[:error]).to be_nil
      expect(changelog[:version]).to eql('1.12.3')
      expect(changelog[:date]).to eql('2025-12-02')
      expect(changelog[:text]).to end_with('newer Android versions')

      File.delete(filename)
    end
    it 'with text' do
      changelog_content = <<~CHANGELOG
        # Changelog

        ## 1.12.3 (2025-12-02)

        ### Fixes
        - fix not all Lockscreen command options working on newer Android versions#{' '}

        ## 1.12.2 (2025-11-18)

        ### Fixes
        - support split-apk (xapk) on older Android versions

        ## 1.12.1 (2025-11-10)

        ### Fixes
        - support byte data on intent command extra
      CHANGELOG

      filename = 'temp_changelog.md'
      File.write(filename, changelog_content)
      changelog = Fastlane::Helper::NordalpAppPublishHelper.read_first_changelog_entry(filename)

      expect(changelog[:error]).to be_nil
      expect(changelog[:version]).to eql('1.12.3')
      expect(changelog[:date]).to eql('2025-12-02')
      expect(changelog[:text]).to end_with('newer Android versions')

      File.delete(filename)
    end
    it 'invalid format' do
      changelog_content = <<~CHANGELOG
        # Changelog

        ### 1.12.3 (2025-12-02)

        #### Fixes
        - fix not all Lockscreen command options working on newer Android versions#{' '}

        ### 1.12.2 (2025-11-18)

        #### Fixes
        - support split-apk (xapk) on older Android versions

        ### 1.12.1 (2025-11-10)

        #### Fixes
        - support byte data on intent command extra
      CHANGELOG

      filename = 'temp_changelog.md'
      File.write(filename, changelog_content)
      changelog = Fastlane::Helper::NordalpAppPublishHelper.read_first_changelog_entry(filename)

      expect(changelog[:error]).should_not(be_nil)

      File.delete(filename)
    end
  end
end
