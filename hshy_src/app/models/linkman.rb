class Linkman < ActiveRecord::Base
  #has_and_belongs_to_many :projects, :class_name=>"Project", :join_table => "project_linkman"
  belongs_to :user, :class_name =>"YtwgUser", :foreign_key=>"user_id"
end
