class CreateHouseWupins < ActiveRecord::Migration
  def self.up
    create_table :house_wupin do |t|
    end
  end

  def self.down
    drop_table :house_wupin
  end
end
