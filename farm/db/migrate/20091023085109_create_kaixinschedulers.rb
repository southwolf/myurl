class CreateKaixinschedulers < ActiveRecord::Migration
  def self.up
    create_table :kaixinschedulers do |t|
      t.datetime :occurtime
      t.timestamps
    end
  end

  def self.down
    drop_table :kaixinschedulers
  end
end
