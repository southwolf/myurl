class AddKaixinUseridToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :kaixinuser_id, :integer
  end

  def self.down
    remove_column :users, :kaixinuser_id
  end
end
