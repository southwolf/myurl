class Email < ActiveRecord::Base
   has_and_belongs_to_many :users, :class_name=>"YtwgUser", :join_table => "user_email", :foreign_key =>'email_id', :association_foreign_key =>'user_id'
   has_and_belongs_to_many :ccusers, :class_name=>"YtwgUser", :join_table => "user_email_cc", :foreign_key =>'email_id', :association_foreign_key =>'user_id'
   has_and_belongs_to_many :readusers, :class_name=>"YtwgUser", :join_table => "user_email_read", :foreign_key =>'email_id', :association_foreign_key =>'user_id'
   file_column :attach
   file_column :attach2
   file_column :attach3
end
