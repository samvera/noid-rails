require 'spec_helper'
require 'active_fedora/noid'
require 'active_fedora/noid/synchronized_minter'

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
    it 'TODO'
  end

  describe '#next_id' do
    it 'TODO'
  end
end
