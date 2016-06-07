# -*- encoding : utf-8 -*-
require 'rails/generators'
require 'rails/generators/migration'

class ActiveFedora::Noid::Install < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)
  desc "Installs ActiveFedora::Noid"

  def banner
    say_status('info', 'GENERATING AF::NOID', :blue)
  end

  def copy_migrations
    # TODO: Add db migrations
  end
end
