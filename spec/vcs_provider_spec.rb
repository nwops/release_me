require 'spec_helper'
require 'release_me/vcs_provider'

describe ReleaseMe::VcsProvider do
  include described_class
  before :each do
    ENV['GITLAB_CI'] = 'true'
  end

  let(:file_path) do
    File.expand_path(File.join('spec', 'providers', 'puppet'))
  end

  it 'can load providers' do
    expect(providers.count).to be >= 1
  end

  describe :gitlab do
    let(:file_path) do
      File.expand_path(File.join('spec', 'adapters', 'puppet'))
    end
    it 'returns provider config' do
      expect(provider_config(file_path)['provider_name']).to eq('gitlab')
    end
  end

  describe :gem do
    let(:file_path) do
      File.expand_path(File.join('spec', 'adapters', 'gem'))
    end
    it 'returns provider config' do
      expect(provider_config(file_path)['provider_name']).to eq('gitlab')
    end
  end

  describe :local do
    before :each do
      ENV['GITLAB_CI'] = nil
    end
    let(:file_path) do
      File.expand_path(File.join('spec', 'adapters', 'local'))
    end
    it 'returns gitlab provider config' do
      expect(provider_config(file_path)['provider_name']).to eq('gitlab')
    end
    it 'returns local config' do
      expect(local_config(file_path)['vcs']['provider']).to eq('gitlab')
    end

    it 'can override base_url' do
      expect(provider_config(file_path)['base_url']).to eq('https://mygitlab.com/api/v3/projects')
    end
  end
end
