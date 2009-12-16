class YtwgNews < ActiveRecord::Base
  set_table_name :boardnews

  has_and_belongs_to_many :users, :class_name=>"YtwgUser", :join_table=>"user_news", :association_foreign_key =>'user_id',  :foreign_key=>'news_id'
end
