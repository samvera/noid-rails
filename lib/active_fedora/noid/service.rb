# frozen_string_literal: true
require 'noid'

module ActiveFedora
  module Noid
    class Service
      attr_reader :minter

      def initialize(minter = default_minter)
        @minter = minter
      end

      delegate :valid?, to: :minter

      delegate :mint, to: :minter

      protected

      def default_minter
        ActiveFedora::Noid.config.minter_class.new
      end
    end
  end
end
