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
        lambda { |uri| URI(uri).path.split('/', 9).last }
      end

      def translate_id_to_uri
        lambda do |id|
          "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{ActiveFedora::Noid.treeify(id)}"
        end
      end
    end
  end
end
