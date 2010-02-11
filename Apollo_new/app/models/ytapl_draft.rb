require 'composite_primary_keys'

class YtaplDraft < ActiveRecord::Base
    set_primary_keys :unitid, :taskid, :tasktimeid
    set_table_name :ytapl_draft
end
