class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :limit=>50
      t.column :count, :integer
    end
  end

  def self.down
    drop_table :tags
  end
end
