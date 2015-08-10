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

      def file_opts
        { encoding: Encoding::ASCII_8BIT }
      end

      def next_id
        id = ''
        ::File.open(statefile, ::File::RDWR|::File::CREAT, 0644, file_opts) do |f|
          f.flock(::File::LOCK_EX)
          state = state_for(f)
          minter = ::Noid::Minter.new(state)
          id = minter.mint
          f.rewind
          new_state = Marshal.dump(minter.dump)
          f.write(new_state.force_encoding(f.external_encoding))
          f.flush
          f.truncate(f.pos)
        end
        id
      end
    end
  end
end
