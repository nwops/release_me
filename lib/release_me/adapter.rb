require 'yaml'
require 'ostruct'
require 'json'
require 'erb'

module ReleaseMe
  module Adapter
    # @return [Hash] - adapter config
    # @param [String] - path to the directory in which you want to check
    def adapter_config(project_path = Dir.pwd)
      path = project_path || Dir.pwd
      config = local_config(path) || detect_adapter_config(path)
      raise 'Cannot find config' if config.nil?
      adapter = OpenStruct.new(config)
      adapter[:version_file] = version_file(adapter, path)
      adapter[:current_version] = current_version(adapter, adapter[:version_file])
      adapter
    end

    def adapter_list
      adapters.keys
    end

    # @return [Hash] adapter settings found in the project directory
    # @param [String] - path to the directory in which you want to check
    def local_config(path = Dir.pwd)
      file = File.join(path, '.release_me.yaml')
      if File.exist?(file)
        data = load_adapter(file)
        data.fetch('adapter', nil)
      end
    end

    def version_file(adapter, path)
      Dir.glob(File.join(path, adapter.version_file_relative_path)).first
    end

    private

    # @param [OpenStruct] - adapter config
    # @param [String] - path to version file
    def current_version(adapter, file)
      file_type = File.extname(file).downcase
      case file_type
      when '.json'
        JSON.parse(File.read(file))[adapter.version_field]
      when '.yaml', '.yml'
        YAML.load_file(file)[adapter.version_field]
      when '.rb'
        # reads in the ruby version file and should return the version if
        # that is the last thing executed
        eval(File.read(file))
        end
    end

    # @return [Hash] - adapter config type
    # @param [String] - path to the directory in which you want to check
    def detect_adapter_config(path = Dir.pwd)
      type, config = adapters.find do |_, adapter_config|
        pattern = File.join(path, adapter_config['detection_pattern']) || ''
        Dir.glob(pattern).count > 0
      end
      config
    end

    # @param [String] path to adapter file
    # @return [Hash] rendered object from YAML
    # renders as an erb file
    def load_adapter(file_name)
      template = ERB.new File.new(file_name).read
      YAML.load(template.result(binding))
    end

    # @return [Hash] adapter types
    def adapters
      unless @adapters
        @adapters = {}
        dir = File.join(File.dirname(File.expand_path(__FILE__)), 'adapters')
        files = Dir.glob(File.join(dir, '*.yaml'))
        files.each do |file_name|
          data = load_adapter(file_name)
          @adapters[data['adapter_name']] = data
        end
      end
      @adapters
    end
  end
end
