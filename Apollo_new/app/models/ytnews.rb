class Ytnews < ActiveRecord::Base
  validates_presence_of :title
  set_table_name :ytapl_news
end
