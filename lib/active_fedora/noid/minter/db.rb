require 'noid'

module ActiveFedora
  module Noid
    module Minter
      class Db < Base
        protected

        # Uses pessimistic lock to ensure the record fetched is the same one updated.
        # Should be fast enough to avoid terrible deadlock.
        # Must lock because of multi-connection context! (transaction is per connection -- not enough)
        # The DB table will only ever have at most one row per namespace.
        # The 'default' namespace row is inserted by `rails generate active_fedora:noid:seed`.
        # If you want another namespace, edit your config initialzer to something like:
        #     ActiveFedora::Noid.config.namespace = 'druid'
        #     ActiveFedora::Noid.config.template = '.reeedek'
        # and in your app run:
        #     bundle exec rails generate active_fedora:noid:seed
        def next_id
          id = nil
          MinterState.transaction do
            state = MinterState.lock.where(
              namespace: ActiveFedora::Noid.config.namespace,
              template: ActiveFedora::Noid.config.template,
            ).first!
            minter = ::Noid::Minter.new(state.noid_options)
            id = minter.mint
            # namespace and template are the same, now update the other attributes
            state.seq      = minter.seq
            state.counters = JSON.generate(minter.counters)
            state.random   = Marshal.dump(minter.instance_variable_get(:@rand))
            state.save!
          end # transaction
          id
        end

      end # class Db
    end
  end
end
