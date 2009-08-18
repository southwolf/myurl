class CreateWeburls < ActiveRecord::Migration
  def self.up
    create_table :weburls do |t|
      t.column :address, :string, :limit=>250
      t.column :desc, :string, :limit=>250
      t.column :logo, :string, :limit=>250
      t.column :catalog_id, :integer
      t.column :recommand_id, :integer
      t.column :user_id, :integer
      t.column :adpot_count, :integer
    end
  end

  def self.down
    drop_table :weburls
  end
end
