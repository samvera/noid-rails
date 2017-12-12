# frozen_string_literal: true

RSpec.describe Noid::Rails::Config do
  subject { described_class.new }

  it { is_expected.to respond_to(:template) }
  it { is_expected.to respond_to(:statefile) }
  it { is_expected.to respond_to(:namespace) }
  it { is_expected.to respond_to(:minter_class) }

  describe '#template' do
    let(:default) { '.reeddeeddk' }

    it 'has a default' do
      expect(subject.template).to eq default
    end

    describe 'overriding' do
      before { subject.template = custom_template }

      let(:custom_template) { '.dddddd' }

      it 'allows setting a custom template' do
        expect(subject.template).to eq custom_template
      end
    end
  end

  describe '#minter_class' do
    let(:default) { Noid::Rails::Minter::File }

    it 'has a default' do
      expect(subject.minter_class).to eq default
    end

    context 'when overridden' do
      before { subject.minter_class = different_minter }
      let(:different_minter) { Noid::Rails::Minter::File }

      it 'uses the different minter' do
        expect(subject.minter_class).to eq different_minter
      end
    end
  end
end
