require 'noid'
require 'active_fedora'

module ActiveFedora
  module Noid
    module Minter
      class Base < ::Noid::Minter
        ##
        # @param template [#to_s] a NOID template
        #
        # @see Noid::Template
        def initialize(template = default_template)
          super(template: template.to_s)
        end

        ##
        # Sychronously mint a new identifier. Guarantees the ID is not
        # already reserved in ActiveFedora.
        #
        # @return [String] the minted identifier
        def mint
          Mutex.new.synchronize do
            while true
              pid = next_id
              return pid unless ActiveFedora::Base.exists?(pid) || ActiveFedora::Base.gone?(pid)
            end
          end
        end

        ##
        # @return [Hash] an object representing the current minter state
        def read
          raise NotImplementedError.new('Implement #read in child class')
        end

        ##
        # Updates the minter state to that of the `minter` parameter.
        #
        # @param minter [Minter::Base]
        #
        # @return [void]
        def write!(_)
          raise NotImplementedError.new('Implement #write! in child class')
        end

        protected

        ##
        # @return [#to_s] the default template for this
        def default_template
          ActiveFedora::Noid.config.template
        end

        ##
        # @return [String] a new identifier.
        def next_id
          raise NotImplementedError.new('Implement #next_id in child class')
        end
      end
    end
  end
end
