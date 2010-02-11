class YtaplUser < ActiveRecord::Base
  set_primary_key :userid
  set_table_name :ytapl_users
  has_and_belongs_to_many :groups, :class_name=>'YtaplGroup', :join_table=>"ytapl_groupmember", :foreign_key =>"userid", :association_foreign_key=>"groupid"
  
  def <=>(other)
    	if EncodeUtil.change("GB2312", "UTF-8", truename) > EncodeUtil.change("GB2312", "UTF-8", other.truename)
    		return 1
      else
        return -1
      end
    end
end
