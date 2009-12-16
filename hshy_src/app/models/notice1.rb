class Notice1 < ActiveRecord::Base
  #has_and_belongs_to_many :users, :class_name=>"YtwgUser", :join_table=>"user_notice", :association_foreign_key =>'user_id',  :foreign_key=>'notice_id'
end
