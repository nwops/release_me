require 'json'
require 'time'
require_relative 'adapter'
# either pass in the tag name or allow the script to create one
#
# outputs the version that was written to the file
module ReleaseMe
  class BumpVersion
    include ReleaseMe::Adapter
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def app_version_file
      app_config.version_file
    end

    def version_type
      options[:version]
    end

    def app_config
      @app_config ||= adapter_config(options[:project_path])
    end

    def new_version
      unless @new_version
        case version_type
          when :commit
            @new_version = `git rev-parse HEAD`.chomp[0..8]
          when :time
            @new_version = Time.now.strftime('%Y.%m.%d.%H%M')
          when :semver
            @new_version = app_config.current_version.next
          else
            @new_version = options[:version] || app_config.current_version.next
        end
      end
      @new_version
    end

    def run
      app_config_lines = File.read(app_config.version_file)
      app_config_lines.gsub!(app_config.current_version, new_version)
      debug_message = "updated version string from #{app_config.current_version} to #{new_version}"
      if options[:json]
        output = JSON.pretty_generate(message: debug_message,
                                  file_content: app_config_lines,
                                  new_version: new_version,
                                  old_version: app_config.current_version)
      else
        STDERR.puts debug_message
        File.write(app_config.version_file, app_config_lines) unless options[:dry_run]
        output = app_config_lines
      end
      output
    end
  end
end


