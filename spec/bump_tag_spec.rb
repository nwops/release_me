require "spec_helper"
require 'release_me/bump_tag'

describe ReleaseMe::BumpTag do
  let(:options) do
    {
        :json => true,
        :project_path => project_path
    }

  end
  before :each do
    ENV['GITLAB_CI'] = 'true'
  end

  let(:project_path) do
    File.expand_path(File.join('spec','adapters', 'puppet'))
  end

  let(:instance) do
    ReleaseMe::BumpTag.new(options)
  end

  it 'create instance' do
    expect(instance).to be_a_kind_of(described_class)
  end

  it 'config' do
    expect(instance.vcs_config).to be_a_kind_of(OpenStruct)
  end

  describe 'gitlab' do
    let(:commit) do
      "{\"id\":3,\"branch_name\":null,\"author_email\":null,\"author_name\":null,\"commit_message\":\"Auto tagged to 0.1.1\",\"actions\":[{\"action\":\"update\",\"file_path\":\"/Users/cosman/github/release_me/lib/release_me/version.rb\",\"content\":\"module ReleaseMe\\n  VERSION = \\\"0.1.1\\\"\\nend\\n\"}]}"
    end
    let(:tag) do
      "{\"id\":3,\"tag_name\":\"0.1.1\",\"ref\":\"12345678943434343\"}"
    end

    before :each do
      ENV['GITLAB_CI'] = 'true'
      ENV['CI_PROJECT_ID'] = '3'
      ENV['CI_PROJECT_URL'] = 'https://gitlab.com/gitlab-org/gitlab-ce'
      ENV['PRIVATE_TOKEN'] = 'dsfasdfasdfasdfasdfasdfasdfasdf'


    end
    let(:project_path) do
      File.expand_path(File.join('spec','adapters', 'local'))
    end
    it 'can run' do
      allow(instance).to receive(:send_data).with(instance.commits_url, commit).and_return('{"id": "12345678943434343"}')
      allow(instance).to receive(:send_data).with(instance.tags_url, tag, :post).and_return('{}')
      expect(instance.run).to eq("Tagged: 0.1.1")
    end
  end

end
