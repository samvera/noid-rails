# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ActiveFedora::Noid::Model do
  let(:sample_class) do
    Class.new(ActiveFedora::Base) do
      include ActiveFedora::Noid::Model
    end
  end
  let(:instance) { sample_class.new }
  let(:service) { instance_double(ActiveFedora::Noid::Service, mint: '1234') }

  before do
    allow(ActiveFedora::Noid::Service).to receive(:new).and_return(service)
  end

  describe '#assign_id' do
    it 'returns the id from the noid service' do
      expect(instance.assign_id).to eq '1234'
    end
  end
end
