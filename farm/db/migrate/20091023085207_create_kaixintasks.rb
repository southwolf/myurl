class CreateKaixintasks < ActiveRecord::Migration
  def self.up
    create_table :kaixintasks do |t|
      t.integer :tasktype
      t.integer :kaixinscheduler_id
      t.integer :kaixinuser_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kaixintasks
  end
end
