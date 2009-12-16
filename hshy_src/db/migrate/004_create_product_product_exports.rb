class CreateProductProductExports < ActiveRecord::Migration
  def self.up
    create_table :product_product_export do |t|
    end
  end

  def self.down
    drop_table :product_product_export
  end
end
