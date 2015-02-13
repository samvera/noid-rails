require 'spec_helper'
require 'active_fedora/noid/config'

describe ActiveFedora::Noid::Config do
  it { is_expected.to respond_to(:template) }
  it { is_expected.to respond_to(:statefile) }
  it { is_expected.to respond_to(:translate_id_to_uri) }
  it { is_expected.to respond_to(:translate_uri_to_id) }

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
end
