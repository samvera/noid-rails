require 'active_fedora/noid/version'
require 'active_fedora/noid/config'
require 'active_fedora/noid/service'
require 'active_fedora/noid/synchronized_minter'

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
        raise ArgumentError, 'Identifier must be a string of size > 0 in order to be treeified' if identifier.blank?
        head = identifier.split('/').first
        head.gsub!(/#.*/, '')
        (head.scan(/..?/).first(4) + [identifier]).join('/')
      end
    end
  end
end
