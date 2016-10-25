# frozen_string_literal: true
require 'active_fedora/noid'
require 'noid'
require 'yaml'

namespace :active_fedora do
  namespace :noid do
    namespace :migrate do
      desc 'Migrate minter state file from YAML to Marshal'
      task :yaml_to_marshal do
        statefile = ENV.fetch('AFNOID_STATEFILE', ActiveFedora::Noid.config.statefile)
        raise "File not found: #{statefile}\nAborting" unless File.exist?(statefile)
        puts "Migrating #{statefile} from YAML to Marshal serialization..."
        File.open(statefile, 'a+b', 0o644) do |f|
          f.flock(File::LOCK_EX)
          f.rewind
          begin
            yaml_state = YAML.load(f)
          rescue Psych::SyntaxError
            raise "File not valid YAML: #{statefile}\nAborting."
          end
          minter = Noid::Minter.new(yaml_state)
          f.truncate(0)
          new_state = Marshal.dump(minter.dump)
          f.write(new_state)
        end
        puts 'Done!'
      end

      desc 'Migrate minter state from file to database'
      task file_to_database: :environment do
        statefile = ENV.fetch('AFNOID_STATEFILE', ActiveFedora::Noid.config.statefile)
        raise "File not found: #{statefile}\nAborting" unless File.exist?(statefile)
        puts "Migrating #{statefile} to database..."
        state = ActiveFedora::Noid::Minter::File.new.read
        minter = Noid::Minter.new(state)
        new_state = ActiveFedora::Noid::Minter::Db.new
        new_state.write!(minter)
        puts 'Done!'
      end

      desc 'Migrate minter state from database to file'
      task database_to_file: :environment do
        statefile = ENV.fetch('AFNOID_STATEFILE', ActiveFedora::Noid.config.statefile)
        raise "File already exists (delete it first if it's not valuable): #{statefile}\nAborting" if File.exist?(statefile)
        puts "Migrating minter state from database to #{statefile}..."
        state = ActiveFedora::Noid::Minter::Db.new.read
        minter = Noid::Minter.new(state)
        new_state = ActiveFedora::Noid::Minter::File.new
        new_state.write!(minter)
        puts 'Done!'
      end
    end
  end
end
