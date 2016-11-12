require "spec_helper"
require 'release_me/adapter'

describe ReleaseMe::Adapter do
  include ReleaseMe::Adapter
  let(:file_path) do
    File.expand_path(File.join('spec','adapters', 'puppet'))
  end

  it "can load adapters" do
    expect(adapters.count).to be >= 2
  end

  describe :puppet do
    let(:file_path) do
      File.expand_path(File.join('spec','adapters', 'puppet'))
    end
    it 'returns adapter config' do
      expect(adapter_config(file_path)['adapter_name']).to eq('puppet')
    end
  end

  describe :gem do
    let(:file_path) do
      File.expand_path(File.join('spec', 'adapters', 'gem'))
    end
    it 'returns adapter config' do
      expect(adapter_config(file_path)['adapter_name']).to eq('gem')
    end
  end

  describe :local do
    let(:file_path) do
      File.expand_path(File.join('spec', 'adapters', 'local'))
    end
    it 'returns adapter config' do
      expect(local_config(file_path)['adapter_name']).to eq('custom')
      expect(adapter_config(file_path)['adapter_name']).to eq('custom')
    end
  end



end
