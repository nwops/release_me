require_relative 'bump_version'
require_relative 'vcs_provider'

module ReleaseMe
  class BumpTag
    attr_reader :options, :version_instance
    include ReleaseMe::VcsProvider

    def initialize(options)
      @options = options
      opts = {
        json: true,
        version: options[:version_type]
      }
      @version_instance = ReleaseMe::BumpVersion.new(opts)
    end

    def private_token
      vcs_config.private_token
    end

    def commits_url
      @commit_url ||= URI("#{project_url}/#{vcs_config.commits_path}")
    end

    def project_url
      @project_url ||= "#{vcs_config.base_url}/#{vcs_config.project_id}"
    end

    def tags_url
      @tags_url ||= URI("#{project_url}/#{vcs_config.tags_path}")
    end

    def vcs_config
      @vcs_config ||= provider_config(options[:project_path])
    end

    # @return [Hash] output from bump version
    def bump_version_file
      JSON.parse(version_instance.run)
    end

    def file_update_body_request(file_contents, message)
      {
        id: vcs_config.project_id,
        branch_name: vcs_config.branch_name,
        author_email: vcs_config.author_email,
        author_name: vcs_config.author_name,
        commit_message: message,
        actions: [
          {
            action: :update,
            file_path: version_instance.app_version_file.gsub(Dir.pwd + '/', ''),
            content: file_contents
          }
        ]
      }.to_json
    end

    def tag_body_request(tag_name, commit_id)
      {
        id: vcs_config.project_id,
        tag_name: tag_name,
        ref: commit_id, # or git rev-parse HEAD
        # messasge:
        # release_description:
      }.to_json
    end

    # @return [String] commit id of submitted body
    def update_version(version_object)
      new_version = version_object['new_version']
      file_content = version_object['file_content']
      message = "Auto tagged to #{new_version}"
      body = file_update_body_request(file_content, message)
      response = send_data(commits_url, body)
      # the id may be specific to gitlab api
      JSON.parse(response)['id']
    end

    # @param [String] - new version string
    # @param [String] - commit it to tag
    # @return [String] - json encoded result from http call
    def tag(version, commit_id)
      body = tag_body_request(version, commit_id)
      send_data(tags_url, body, :post)
    end

    # @param [URI] uri of the request
    # @param [Object] Body of request is a hash or array
    # @param [:put or :post] method to use when sending data to gitlab
    # @return [String] message body for url call in JSON format
    def send_data(uri, body, method = nil)
      use_ssl = uri.scheme == 'https'
      conn = Net::HTTP.new(uri.host, uri.port)
      # conn.set_debug_output
      conn.use_ssl = use_ssl
      # Don't verify
      conn.verify_mode = OpenSSL::SSL::VERIFY_NONE if vcs_config.no_verify
      request = case method
                when :put
                  Net::HTTP::Put.new(uri.path)
                else
                  Net::HTTP::Post.new(uri.path)
                end
      request.body = body
      # private token is specific to gitlab and must be set
      request['PRIVATE-TOKEN'] = vcs_config.private_token
      request.content_type = 'application/json'
      if options[:dry_run]
        puts body
      else
        response = conn.request(request)
        if response.is_a? Net::HTTPSuccess
          response.body
        else
          puts response.code
          puts response.body
          exit 1
        end
      end
    end

    def run
      version_output = bump_version_file
      unless options[:dry_run]
        commit_id = update_version(version_output)
        tag(version_output['new_version'], commit_id) unless @options[:no_tagging]
      end
      "Tagged: #{version_output['new_version']}"
    end
  end
end
