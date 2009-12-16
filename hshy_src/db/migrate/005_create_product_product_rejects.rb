class CreateProductProductRejects < ActiveRecord::Migration
  def self.up
    create_table :product_product_reject do |t|
    end
  end

  def self.down
    drop_table :product_product_reject
  end
end
