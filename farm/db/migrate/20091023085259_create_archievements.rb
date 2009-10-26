class CreateArchievements < ActiveRecord::Migration
  def self.up
    create_table :archievements do |t|
      t.integer :user_id
      t.string :desc
      t.timestamps
    end
  end

  def self.down
    drop_table :archievements
  end
end
