require 'spec_helper'

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

  describe '#translate_uri_to_id' do
    let(:translator) { described_class.new.translate_uri_to_id }
    let(:uri) { "http://localhost:8983/fedora/rest/test/hh/63/vz/22/hh63vz22q/members" }
    subject { translator.call(uri) }

    it { is_expected.to eq 'hh63vz22q/members' }
  end
end
