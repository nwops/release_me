require 'spec_helper'
require 'release_me/vcs_provider'

describe ReleaseMe::VcsProvider do
  include described_class
  before :each do
    ENV['GITLAB_CI'] = 'true'
    ENV['CI_PROJECT_URL'] = 'https://github.com/api/v3/projects/1'
    ENV['CI_PROJECT_ID'] = '1'
    ENV['PRIVATE_TOKEN'] = '1234'
  end
  let(:config) do
    provider_config(project_path)
  end
  let(:project_path) do
    File.expand_path(File.join('spec', 'providers', 'puppet'))
  end

  it 'can load providers' do
    expect(providers.count).to be >= 1
  end

  describe :gitlab do
    let(:project_path) do
      File.expand_path(File.join('spec', 'adapters', 'puppet'))
    end
    it 'returns provider config' do
      expect(config['provider_name']).to eq('gitlab')
    end
  end

  describe :gem do
    let(:project_path) do
      File.expand_path(File.join('spec', 'adapters', 'gem'))
    end
    it 'returns provider config' do
      expect(config['provider_name']).to eq('gitlab')
    end
  end

  describe :local do
    before :all do
      ENV['GITLAB_CI'] = 'true'
      ENV['CI_PROJECT_URL'] = 'https://github.com/api/v3/projects/1'
      ENV['CI_PROJECT_ID'] = '1'
      ENV['PRIVATE_TOKEN'] = '1234'
    end
    let(:project_path) do
      File.expand_path(File.join('spec', 'adapters', 'local'))
    end
    it 'returns gitlab provider config' do
      expect(config['provider_name']).to eq('gitlab')
    end
    it 'returns local config' do
      expect(config['provider']).to eq('gitlab')
    end

    it 'can override base_url' do
      expect(config['base_url']).to eq('https://mygitlab.com/api/v3/projects')
    end

    it 'can override author name' do
      expect(config['author_name']).to eq('Autobot')
    end

    it 'can override author email' do
      expect(config['author_email']).to eq('autobot@nwops.io')
    end
  end
end
