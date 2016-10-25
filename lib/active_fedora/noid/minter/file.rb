# frozen_string_literal: true
require 'noid'

module ActiveFedora
  module Noid
    module Minter
      class File < Base
        attr_reader :statefile

        def initialize(template = default_template, statefile = default_statefile)
          @statefile = statefile
          super(template)
        end

        def default_statefile
          ActiveFedora::Noid.config.statefile
        end

        def read
          with_file do |f|
            state_for(f)
          end
        end

        def write!(minter)
          with_file do |f|
            # Wipe prior contents so the new state can be written from the beginning of the file
            f.truncate(0)
            f.write(Marshal.dump(minter.dump))
          end
        end

        protected

        def with_file
          ::File.open(statefile, 'a+b', 0o644) do |f|
            f.flock(::File::LOCK_EX)
            # Files opened in append mode seek to end of file
            f.rewind
            yield f
          end
        end

        def state_for(io_object)
          Marshal.load(io_object.read)
        rescue TypeError, ArgumentError
          { template: template }
        end

        def next_id
          state = read
          state[:template] &&= state[:template].to_s
          minter = ::Noid::Minter.new(state) # minter w/in the minter, lives only for an instant
          id = minter.mint
          write!(minter)
          id
        end
      end
    end
  end
end
