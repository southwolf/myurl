class Righttype < ActiveRecord::Base
  has_many :rights, :class_name=>"YtwgRight", :foreign_key=>"cata_id", :order=>"position"
end
