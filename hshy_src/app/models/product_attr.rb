class ProductAttr < ActiveRecord::Base
   has_many :composite, :class_name=>"ProductComposite", :foreign_key=>"p_id"
end
