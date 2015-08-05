module ActiveFedora
  module Noid
    class Config
      attr_writer :template, :translate_uri_to_id, :translate_id_to_uri, :statefile

      def template
        @template ||= '.reeddeeddk'
      end

      def statefile
        @statefile ||= '/tmp/minter-state'
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
