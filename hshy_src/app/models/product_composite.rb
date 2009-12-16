class ProductComposite < ActiveRecord::Base
    belongs_to :parent, :class_name=>"ProductCata", :foreign_key=>"p_id"
    belongs_to :material, :class_name=>"ProductCata", :foreign_key=>"sub_id"
end
