class Ytauditinfo < ActiveRecord::Base
  set_primary_keys :unitid, :taskid, :tasktimeid
  set_table_name :ytapl_auditinfo
end
