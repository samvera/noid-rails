require 'spec_helper'

describe ActiveFedora::Noid do
  describe '#configure' do
    it { is_expected.to respond_to(:configure) }
  end

  describe '#config' do
    it 'returns a config object' do
      expect(subject.config).to be_instance_of ActiveFedora::Noid::Config
    end
  end

  describe '#treeify' do
    subject { ActiveFedora::Noid.treeify(id) }
    let(:id) { 'abc123def45' }
    it { is_expected.to eq 'ab/c1/23/de/abc123def45' }
  end
end
