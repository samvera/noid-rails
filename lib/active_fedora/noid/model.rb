# frozen_string_literal: true

module ActiveFedora
  module Noid
    # Mix this class into an ActiveFedora:Base model in order to have you new objects
    # created with a noid id.
    module Model
      ## This overrides the default behavior, which is to ask Fedora for an id
      # @see ActiveFedora::Persistence.assign_id
      def assign_id
        service.mint
      end

      private

      def service
        @service ||= ActiveFedora::Noid::Service.new
      end
    end
  end
end
