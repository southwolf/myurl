class CreateProductComposites < ActiveRecord::Migration
  def self.up
    create_table :product_composite do |t|
    end
  end

  def self.down
    drop_table :product_composite
  end
end
