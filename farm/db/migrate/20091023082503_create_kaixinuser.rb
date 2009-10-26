class CreateKaixinuser < ActiveRecord::Migration
  def self.up
    create_table :kaixinusers do |t|
      t.string :name, :limit=>40
      t.string :password, :limit=>40
      t.text   :friends
      t.timestamps
    end
  end

  def self.down
    drop_table :kaixinusers
  end
end
