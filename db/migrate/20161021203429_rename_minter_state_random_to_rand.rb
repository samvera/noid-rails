# frozen_string_literal: true
class RenameMinterStateRandomToRand < ActiveRecord::Migration
  def change
    rename_column :minter_states, :random, :rand
  end
end
