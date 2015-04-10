require 'digest/md5'

module ActiveFedora
  module Noid
    class Config
      attr_writer :template, :translate_uri_to_id, :translate_id_to_uri, :statefile, :treeifier

      def template
        @template ||= '.reeddeeddk'
      end

      def statefile
        @statefile ||= '/tmp/minter-state'
      end

      # Default behavior turns an identifier into a completely unpredictable
      # base-16 value for well-distributed "buckets", none of which can have
      # more than 256 items (at least until asset count is in the billions)
      def treeifier
        @treeifier ||= ->(id) do
          if ActiveFedora::Noid::Service.new.valid?(id)
            Digest::MD5.hexdigest(id)
          else
            id
          end
        end
      end

      def translate_uri_to_id
        lambda { |uri| uri.to_s.split('/')[-1] }
      end

      def translate_id_to_uri
        lambda do |id|
          "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{ActiveFedora::Noid.treeify(id)}"
        end
      end
    end
  end
end
