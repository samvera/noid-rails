require 'noid'

module ActiveFedora
  module Noid
    module Minter
      class Base < ::Noid::Minter
        def initialize(template = default_template)
          super(:template => template.to_s)
        end

        def mint
          Mutex.new.synchronize do
            while true
              pid = next_id
              return pid unless ActiveFedora::Base.exists?(pid) || ActiveFedora::Base.gone?(pid)
            end
          end
        end

        protected

        def default_template
          ActiveFedora::Noid.config.template
        end

        def next_id
          raise NotImplementedError.new('Implement next_id in child class')
        end
      end
    end
  end
end
