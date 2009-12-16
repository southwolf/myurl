class CreateTips < ActiveRecord::Migration
  def self.up
    create_table :tip do |t|
    end
  end

  def self.down
    drop_table :tip
  end
end
