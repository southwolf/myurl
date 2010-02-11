require 'composite_primary_keys'
class Ytunitpermissions < ActiveRecord::Base
  set_primary_keys :groupid, :taskid, :unitid
  set_table_name :ytapl_unitpermissions
end
