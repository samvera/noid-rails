# frozen_string_literal: true
module ActiveFedora
  module Noid
    class Config
      attr_writer :template, :translate_uri_to_id, :translate_id_to_uri,
                  :statefile, :namespace, :minter_class

      def template
        @template ||= '.reeddeeddk'
      end

      def statefile
        @statefile ||= '/tmp/minter-state'
      end

      def namespace
        @namespace ||= 'default'
      end

      def minter_class
        @minter_class ||= Minter::File
      end

      def translate_uri_to_id
        lambda do |uri|
          uri.to_s.sub(baseurl, '').split('/', baseparts).last
        end
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
        2 + [(template.gsub(/\.[rsz]/, '').length.to_f / 2).ceil, 4].min
      end
    end
  end
end
