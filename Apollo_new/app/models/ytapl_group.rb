class YtaplGroup < ActiveRecord::Base
    set_primary_key :groupid
    set_table_name :ytapl_groups
    
    has_and_belongs_to_many :users, :class_name=>"YtaplUser", :join_table=>"ytapl_groupmember", :foreign_key => "groupid", :association_foreign_key=>"userid"
    has_and_belongs_to_many :tasks, :class_name=>"Task", :join_table=>"ytapl_taskvisible", :foreign_key => "groupid", :association_foreign_key=>"taskid"

    def <=>(other)
    	if EncodeUtil.change("GB2312", "UTF-8", name) > EncodeUtil.change("GB2312", "UTF-8", other.name)
    		return 1
      else
        return -1
      end
    end
end
