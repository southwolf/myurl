class Project < ActiveRecord::Base
  has_many :progress
  #has_and_belongs_to_many :units, :class_name=>"Unit", :join_table => "project_unit"
  #has_and_belongs_to_many :linkmen, :class_name=>"Linkman", :join_table => "project_linkman"
end
