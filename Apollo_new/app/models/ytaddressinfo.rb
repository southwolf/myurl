require 'composite_primary_keys'
class Ytaddressinfo < ActiveRecord::Base
  set_primary_keys :unitid
  set_table_name :ytapl_addressinfo
end
