class CreateWupins < ActiveRecord::Migration
  def self.up
    create_table :wupin do |t|
    end
  end

  def self.down
    drop_table :wupin
  end
end
