class YtaplRole < ActiveRecord::Base
    set_primary_key :roleid
    set_table_name :ytapl_roles
    
    has_and_belongs_to_many :rights, :class_name=>"YtaplRight", :join_table=>"ytapl_roleright", :foreign_key =>'role_id', :association_foreign_key =>'right_id'
end
