require 'spec_helper'
require 'active_fedora/noid'

describe ActiveFedora::Noid do
  describe '#configure' do
    it { is_expected.to respond_to(:configure) }
  end

  describe '#config' do
    it 'returns a config object' do
      expect(subject.config).to be_instance_of ActiveFedora::Noid::Config
    end
  end
end
