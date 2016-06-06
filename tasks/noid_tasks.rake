require 'active_fedora/noid'
require 'noid'
require 'yaml'

namespace :active_fedora do
  namespace :noid do
    desc 'Migrate minter state file from YAML to Marshal'
    task :migrate_statefile do
      statefile = ENV.fetch('AFNOID_STATEFILE', ActiveFedora::Noid.config.statefile)
      raise "File not found: #{statefile}\nAborting" unless File.exist?(statefile)
      puts "Migrating #{statefile} from YAML to Marshal serialization..."
      File.open(statefile, 'a+b', 0644) do |f|
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
      puts "Done!"
    end
  end
end
