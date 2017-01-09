# frozen_string_literal: true
module ActiveFedora
  module Noid
    class SeedGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)
      argument :namespace, type: :string, default: ActiveFedora::Noid.config.namespace
      argument :template, type: :string, default: ActiveFedora::Noid.config.template

      desc <<-END_OF_DESC
Seeds DB from ActiveFedora::Noid.config (or command-line overrides)
      END_OF_DESC

      def banner
        say_status('info', "Initializing database table for namespace:template of '#{namespace}:#{template}'", :blue)
      end

      def checks
        say_status('warn', "Be sure to use an initializer to do 'ActiveFedora::Noid.config.namespace = #{namespace}'", :red) if namespace != ActiveFedora::Noid.config.namespace
        say_status('warn', "Be sure to use an initializer to do 'ActiveFedora::Noid.config.template = #{template}'", :red) if template != ActiveFedora::Noid.config.template
      end

      def seed_row
        MinterState.seed!(
          namespace: namespace,
          template: template
        )
      end
    end
  end
end
