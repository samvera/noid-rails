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
        @treeifier ||= ->(id) { Digest::MD5.hexdigest(id) }
      end

      def translate_uri_to_id
        lambda { |uri| URI(uri).path.split('/', baseparts).last }
      end

      def translate_id_to_uri
        lambda do |id|
          "#{baseurl}/#{ActiveFedora::Noid.treeify(id)}"
        end
      end

      private

      def baseurl
        "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}"
      end

      def baseparts
        treeparts = [(template.gsub(/\.[rsz]/,'').length.to_f/2).ceil, 4].min
        baseurl.count('/') + treeparts
      end
    end
  end
end
