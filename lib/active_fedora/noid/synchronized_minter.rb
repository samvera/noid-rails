require 'noid'
module ActiveFedora
  module Noid
    class SynchronizedMinter
      attr_reader :template, :statefile

      def initialize(template = default_template, statefile = default_statefile)
        @template = template
        @statefile = statefile
      end

      def mint
        Mutex.new.synchronize do
          while true
            pid = next_id
            return pid unless ActiveFedora::Base.exists?(pid)
          end
        end
      end

      def valid?(identifier)
        ::Noid::Minter.new(template: template).valid?(identifier)
      end

      protected

      def default_template
        @template ||= ActiveFedora::Noid.config.template
      end

      def default_statefile
        @statefile ||= ActiveFedora::Noid.config.statefile
      end

      def state_for(io_object)
        Marshal.load(io_object.read)
      rescue TypeError, ArgumentError
        { template: template }
      end

      def next_id
        id = ''
        ::File.open(statefile, 'a+b', 0644) do |f|
          f.flock(::File::LOCK_EX)
          # Files opened in append mode seek to end of file
          f.rewind
          state = state_for(f)
          minter = ::Noid::Minter.new(state)

          id = minter.mint

          # Wipe prior contents so the new state can be written from the beginning of the file
          f.truncate(0)
          new_state = Marshal.dump(minter.dump)
          f.write(new_state)
        end
        id
      end
    end
  end
end
