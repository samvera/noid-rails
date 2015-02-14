require 'noid'
require 'yaml'

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

      def next_id
        id = ''
        ::File.open(statefile, ::File::RDWR|::File::CREAT, 0644) do |f|
          f.flock(::File::LOCK_EX)
          yaml = ::YAML::load(f.read) || { template: template }
          minter = ::Noid::Minter.new(yaml)
          id = minter.mint
          f.rewind
          yaml = ::YAML::dump(minter.dump)
          f.write yaml
          f.flush
          f.truncate(f.pos)
        end
        id
      end
    end
  end
end
