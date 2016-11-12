require "spec_helper"
require 'release_me/bump_tag'

describe ReleaseMe::BumpTag do
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
    ReleaseMe::BumpTag.new(options)
  end

  it 'create instance' do
    expect(instance).to be_a_kind_of(described_class)
  end

  it 'config' do
    expect(instance.vcs_config).to eq({})
  end

end
