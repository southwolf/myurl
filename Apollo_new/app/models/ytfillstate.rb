require 'composite_primary_keys'

class Ytfillstate < ActiveRecord::Base
  set_primary_keys :unitid, :taskid, :tasktimeid
  set_table_name :ytapl_fillstate
end
