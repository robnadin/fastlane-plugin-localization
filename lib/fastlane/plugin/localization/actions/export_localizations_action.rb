require 'tmpdir'

module Fastlane
  module Actions
    class ExportLocalizationsAction < Action
      def self.run(params)
        destination_path = params[:destination_path]
        project = params[:project]
        languages = params[:languages]

        UI.message("Exporting localizations from #{project} to #{destination_path} folder")

        if !params[:use_xcloc] && Helper.xcode_at_least?('10.0')
          old_destination_path = File.expand_path(destination_path)
          destination_path = Dir.mktmpdir('export_l10n_output')
        end

        command = []
        command << "xcodebuild"
        command << "-exportLocalizations"
        command << "-localizationPath #{destination_path.shellescape}"
        command << "-project #{project.shellescape}"
        command << languages.map {|lang| "-exportLanguage #{lang}"} if !languages.nil?
        # FastlaneCore::Helper.backticks(command.join(" "), print: !Gym.config[:silent])
        FastlaneCore::Helper.backticks(command.join(" "), print: true)

        if !params[:use_xcloc] && Helper.xcode_at_least?('10.0')
          xliff_files = Dir.glob(File.join(destination_path, '*.xcloc', 'Localized Contents', '*.xliff'))
          FileUtils.mv(xliff_files, FileUtils.mkdir_p(old_destination_path))
        end
      end

      def self.description
        "Export app localizations with help of xcodebuild -exportLocalizations tool"
      end

      def self.authors
        ["vmalyi", "robnadin"]
      end

      def self.available_options
        [
           FastlaneCore::ConfigItem.new(key: :destination_path,
                                   env_name: "EXPORT_LOC_DESTINATION_PATH",
                                description: "Destination path where XLIFF will be exported to",
                                   optional: false,
                                       type: String,
                              default_value: '.'),
           FastlaneCore::ConfigItem.new(key: :project,
                                   env_name: "EXPORT_LOC_PROJECT",
                                description: "Project to export localizations from",
                                   optional: false,
                                       type: String),
           FastlaneCore::ConfigItem.new(key: :languages,
                                   env_name: "EXPORT_LOC_LANGUAGES",
                                description: "Specifies multiple ISO 639-1 languages included in a localization export",
                                       type: Array,
                                   optional: true,
                      default_value_dynamic: true),
           FastlaneCore::ConfigItem.new(key: :use_xcloc,
                                   env_name: "EXPORT_LOC_USE_XCLOC",
                                description: "Use the Xcode Localization Catalog format on Xcode 10.0 and newer",
                                       type: Boolean,
                                   optional: false,
                              default_value: true)
        ]
      end

      def self.is_supported?(platform)
          true
      end
    end
  end
end
