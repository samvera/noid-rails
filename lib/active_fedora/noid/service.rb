require 'noid'

module ActiveFedora
  module Noid
    class Service
      attr_reader :minter

      def initialize(minter = default_minter)
        @minter = minter
      end

      def valid?(identifier)
        minter.valid? identifier
      end

      def mint
        minter.mint
      end

      protected

      def default_minter
        ActiveFedora::Noid.config.minter_class.new
      end
    end
  end
end
