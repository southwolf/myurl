class Task < ActiveRecord::Base
  set_primary_key :taskid
  set_table_name :ytapl_tasks
  validates_uniqueness_of :strid
  
  has_and_belongs_to_many :groups, :class_name=>"YtaplGroup", :join_table=>"ytapl_taskvisible", :foreign_key=>"taskid", :association_foreign_key=>"groupid"

  def <=>(other)
    return 1 if self['position'].to_s.to_i > other['position'].to_s.to_i
    return -1
  end
  
  def view
    return self['content']
  end
  
  def view=(other)
    self['content'] = other
  end
  
end
