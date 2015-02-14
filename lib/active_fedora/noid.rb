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

      def treeify(identifier)
        (identifier.scan(/..?/).first(4) + [identifier]).join('/')
      end
    end
  end
end
