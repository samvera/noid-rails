module ActiveFedora
  module Noid
    class InstallGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      desc <<-END_OF_DESC
Copies DB migrations
      END_OF_DESC

      def banner
        say_status('info', 'Installing ActiveFedora::Noid', :blue)
      end

      def migrations
        rake 'active_fedora_noid_engine:install:migrations'
        rake 'db:migrate'
      end

      def seed
        generate 'active_fedora:noid:seed'
      end
    end
  end
end
