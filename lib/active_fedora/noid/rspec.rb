# frozen_string_literal: true
module ActiveFedora
  module Noid
    ##
    # Provides a test minter conforming to the `ActiveFedora::Noid::Minter`
    # interface for use in unit tests. The test minter is faster and avoids
    # unexpected interactions with cleanup code commonly runs in test suites
    # (e.g. database cleanup).
    #
    # Applications should reenable their production minter for integration tests
    # when appropriate
    #
    # @example general use
    #   ActiveFedora::Noid::RSpec.disable_production_minter!
    #   # some unit tests with the test minter
    #   ActiveFedora::Noid::RSpec.enable_production_minter!
    #   # some integration tests with the original minter
    #
    # @example using a custom test minter
    #   ActiveFedora::Noid::RSpec.disable_production_minter!(test_minter: Minter)
    #
    # @example use when included in RSpec config
    #   require 'active_fedora/noid/rspec'
    #
    #   RSpec.configure do |config|
    #     config.include(ActiveFedora::Noid::RSpec)
    #   end
    #
    #   before(:suite) { disable_production_minter! }
    #   after(:suite)  { enable_production_minter! }
    #
    module RSpec
      DEFAULT_TEST_MINTER = ActiveFedora::Noid::Minter::File

      ##
      # Replaces the configured production minter with a test minter.
      #
      # @param test_minter [Class] an ActiveFedora::Noid::Minter implementation
      #   to use as a replacement minter
      # @return [void]
      def disable_production_minter!(test_minter: DEFAULT_TEST_MINTER)
        return nil if @original_minter

        @original_minter = ActiveFedora::Noid.config.minter_class

        ActiveFedora::Noid.configure do |noid_config|
          noid_config.minter_class = test_minter
        end
      end

      ##
      # Re-enables the original configured minter.
      #
      # @return [void]
      def enable_production_minter!
        return nil unless @original_minter

        ActiveFedora::Noid.configure do |noid_config|
          noid_config.minter_class = @original_minter
        end

        @original_minter = nil
      end
    end
  end
end
