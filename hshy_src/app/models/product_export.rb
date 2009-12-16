class ProductExport < ActiveRecord::Base
  has_and_belongs_to_many :product, :class_name=>"Product", :join_table=>"product_product_export",
    :foreign_key => "e_id", :association_foreign_key =>"p_id"
end
