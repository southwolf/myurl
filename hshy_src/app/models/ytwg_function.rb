class YtwgFunction < ActiveRecord::Base
  acts_as_tree :foreign_key =>"parent_id", :order=>"position"
end
