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
    let(:noid) { '2514nz446' }
    let(:uuid) { '4a48496a-d56b-44a0-9836-e3381dfe13bd' }
    let(:id) { noid }

    context "with the default treeifier" do
      context "on a valid noid" do
        subject { ActiveFedora::Noid.treeify(id) }
        it { is_expected.to eq 'be/19/d0/b2/2514nz446' }
      end

      context "on a non-noid" do
        subject { ActiveFedora::Noid.treeify(id) }
        let(:id) { uuid }
        it { is_expected.to eq '4a/48/49/6a/4a48496a-d56b-44a0-9836-e3381dfe13bd' }
      end
    end

    context "with overridden treeifier" do
      subject { ActiveFedora::Noid.treeify(id) }
      before do
        allow(ActiveFedora::Noid.config).to receive(:treeifier).and_return(->(id) { "custom" })
      end
      it { is_expected.to eq 'cu/st/om/2514nz446' }
    end
  end
end
