require 'yaml'
require 'erb'

module ReleaseMe
  module VcsProvider

    # @return [Hash] - adapter config
    # @param [String] - path to the directory in which you want to check
    def provider_config(project_path = Dir.pwd)
      path = project_path || Dir.pwd
      config = local_config(path) || detect_provider_config
      raise "Cannot find config" if config.nil?
      if vcs = config.fetch('vcs', nil)
        pdata = provider_data(vcs['provider'])
        config.merge(pdata) # merge and override the local vcs data
      end
      OpenStruct.new(config)
    end

    private

    def provider_data(provider)
      load_provider(File.join(provider_dir, "#{provider}.yaml"))
    end

    # @return [Hash] adapter settings found in the project directory
    # @param [String] - path to the directory in which you want to check
    def local_config(path = Dir.pwd)
      file = File.join(path, '.release_me.yaml')
      load_provider(file) if File.exists?(file)
    end

    # @param [String] path to adapter file
    # @return [Hash] rendered object from YAML
    # renders as an erb file
    def load_provider(file_name)
      template = ERB.new File.read(file_name)
      YAML.load(template.result(binding))
    end

    # @return [Hash] - adapter config type
    # @param [String] - path to the directory in which you want to check
    def detect_provider_config
      type, config = providers.find do | _, c|
        c['detected']  # return first provider that could be used
      end
      config
    end

    def provider_dir
      @provider_dir ||= File.join(File.dirname(File.expand_path(__FILE__)), 'vcs_providers')
    end

    # @return [Hash] provider types
    def providers
      unless @providers
        @providers = {}
        files =  Dir.glob(File.join(provider_dir, '*.yaml'))
        files.each do |file_name|
          data = load_provider(file_name)
          @providers[data['provider_name']] = data
        end
      end
      @providers
    end

  end
end