require 'composite_primary_keys'
class Ytgroupmember < ActiveRecord::Base
  set_primary_keys :groupid, :userid
  set_table_name :ytapl_groupmember
end
