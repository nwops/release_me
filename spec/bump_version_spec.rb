require "spec_helper"
require 'release_me/bump_version'

describe ReleaseMe::BumpVersion do
  let(:options) do
    {
        :json => true,
        :project_path => project_path
    }
  end

  let(:project_path) do
    File.expand_path(File.join('spec','adapters', 'puppet'))
  end

  let(:instance) do
    ReleaseMe::BumpVersion.new(options)
  end

  it 'create instance' do
    expect(instance).to be_a_kind_of(described_class)
  end

  describe 'semver' do
    it 'run' do
      data = JSON.parse(instance.run)
      expect(data['new_version']).to eq('2.2.1')
    end
  end
end
