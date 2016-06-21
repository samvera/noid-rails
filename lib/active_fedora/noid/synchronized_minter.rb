require 'noid'

module ActiveFedora
  module Noid
    class SynchronizedMinter < Minter::Base
      attr_reader :statefile

      def initialize(template = default_template, statefile = default_statefile)
        super(template)
        @statefile = statefile
      end

      protected

      def default_statefile
        ActiveFedora::Noid.config.statefile
      end

      def state_for(io_object)
        Marshal.load(io_object.read)
      rescue TypeError, ArgumentError
        { template: template }
      end

      def next_id
        id = nil
        ::File.open(statefile, 'a+b', 0644) do |f|
          f.flock(::File::LOCK_EX)
          # Files opened in append mode seek to end of file
          f.rewind
          state = state_for(f)
          state[:template] &&= state[:template].to_s
          minter = ::Noid::Minter.new(state) # minter w/in the minter, lives only for an instant
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
