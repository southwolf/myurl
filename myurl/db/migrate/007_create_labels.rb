class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table :labels do |t|
      t.column :name, :string, :limit=>50
      t.column :order, :integer
    end
  end

  def self.down
    drop_table :labels
  end
end
