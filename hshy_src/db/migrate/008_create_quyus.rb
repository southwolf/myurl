class CreateQuyus < ActiveRecord::Migration
  def self.up
    create_table :quyu do |t|
    end
  end

  def self.down
    drop_table :quyu
  end
end
