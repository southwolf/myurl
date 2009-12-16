class Product < ActiveRecord::Base
    belongs_to :cata, :class_name => "ProductCata", :foreign_key=>"_cata_id"
    acts_as_tree :foreign_key => "_parent_id"
end
