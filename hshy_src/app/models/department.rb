class Department < ActiveRecord::Base
  belongs_to :leader, :class_name => "YtwgUser", :foreign_key=>"leader_id"
  has_many :users, :class_name =>"YtwgUser", :order=>"position"
  acts_as_tree :foreign_key =>"parent_id", :order=>"position"
  
  has_and_belongs_to_many :quyus
end
