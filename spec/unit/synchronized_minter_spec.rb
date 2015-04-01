require 'spec_helper'
require 'active_fedora'

describe ActiveFedora::Noid::SynchronizedMinter do
  it { is_expected.to respond_to(:mint) }

  it 'has a default template' do
    expect(subject.template).to eq ActiveFedora::Noid.config.template
  end

  it 'has a default template' do
    expect(subject.template).to eq ActiveFedora::Noid.config.template
  end

  describe '#initialize' do
    let(:template) { '.rededk' }
    let(:statefile) { '/tmp/foobar' }

    subject { ActiveFedora::Noid::SynchronizedMinter.new(template, statefile) }

    it 'respects the custom template' do
      expect(subject.template).to eq template
    end

    it 'respects the custom statefile' do
      expect(subject.statefile).to eq statefile
    end
  end

  describe '#mint' do
    before do
      allow(ActiveFedora::Base).to receive(:exists?).and_return(false)
    end

    subject { ActiveFedora::Noid::Service.new.mint }

    it { is_expected.not_to be_empty }

    it 'does not mint the same ID twice in a row' do
      expect(subject).not_to eq ActiveFedora::Noid::Service.new.mint
    end

    it 'is valid' do
      expect(ActiveFedora::Noid::Service.new.valid?(subject)).to be true
    end
  end

  context "when the pid already exists in Fedora" do
    let(:existing_pid) { 'ef12ef12f' }
    let(:unique_pid) { 'bb22bb22b' }

    before do
      allow_any_instance_of(ActiveFedora::Noid::SynchronizedMinter).to receive(:next_id).and_return(existing_pid, unique_pid)
      allow(ActiveFedora::Base).to receive(:exists?).with(existing_pid).and_return(true)
      allow(ActiveFedora::Base).to receive(:exists?).with(unique_pid).and_return(false)
    end

    it 'skips the existing pid' do
      expect(subject.mint).to eq unique_pid
    end
  end
end
