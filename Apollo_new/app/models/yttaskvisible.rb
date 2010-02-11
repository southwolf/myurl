require 'composite_primary_keys'

class Yttaskvisible < ActiveRecord::Base
  set_primary_keys :taskid, :groupid
  set_table_name :ytapl_taskvisible
end
