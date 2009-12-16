class ProductBatch < ActiveRecord::Base
   belongs_to :cata, :class_name=>"ProductCata", :foreign_key=>"_cata_id"
end
