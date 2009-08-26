class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.column :label_id, :integer
      t.column :address, :string, :limit=>200
      t.column :name, :string, :limit=>200
      t.column :desc, :string, :limit=>200
      t.column :green, :integer
      t.column :ticks, :integer
    end
  end

  def self.down
    drop_table :sites
  end
end
