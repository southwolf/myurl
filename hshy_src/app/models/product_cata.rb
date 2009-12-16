class ProductCata < ActiveRecord::Base
   has_one :product_attr, :foreign_key => "id"
   has_many :composite, :class_name=>"ProductComposite", :foreign_key=>"p_id"
end
