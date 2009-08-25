class CreateHots < ActiveRecord::Migration
  def self.up
    create_table :hots do |t|
      t.column :user_id, :integer
      t.column :address, :string, :limit=>200
      t.column :name, :string, :limit=>200
    end
  end

  def self.down
    drop_table :hots
  end
end
