class CreateCatalogs < ActiveRecord::Migration
  def self.up
    create_table :catalogs do |t|
      t.column :user_id, :integer
      t.column :name, :string, :limit=>50
      t.column :parent_id, :integer
    end
  end

  def self.down
    drop_table :catalogs
  end
end
