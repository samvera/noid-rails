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
