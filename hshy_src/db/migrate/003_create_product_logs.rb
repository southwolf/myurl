class CreateProductLogs < ActiveRecord::Migration
  def self.up
    create_table :product_log do |t|
    end
  end

  def self.down
    drop_table :product_log
  end
end
