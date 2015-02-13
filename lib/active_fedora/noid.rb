require 'active_fedora/noid/version'
require 'active_fedora/noid/config'

module ActiveFedora
  module Noid
    class << self
      def configure(&block)
        yield config
      end

      def config
        @config ||= Config.new
      end
    end
  end
end
