class YtwgGroup < ActiveRecord::Base
  has_and_belongs_to_many :rights, :class_name=>"YtwgRight", :join_table=>"ytwg_groupright", :foreign_key =>'group_id', :association_foreign_key =>'right_id'
end
