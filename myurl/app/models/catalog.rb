class Catalog < ActiveRecord::Base
  set_table_name :catalogs
  acts_as_tree
end
