class YtwgUser < ActiveRecord::Base
  has_and_belongs_to_many :groups, :class_name=>"YtwgGroup", :join_table=>"ytwg_usergroup", :foreign_key =>'user_id', :association_foreign_key =>'group_id'
#  has_and_belongs_to_many :votes, :class_name=>"Vote", :join_table=>"vote_user", :foreign_key =>'user_id', :association_foreign_key =>'vote_id'
  has_and_belongs_to_many :notices, :class_name=>"Notice", :join_table=>"user_notice", :foreign_key =>'user_id', :association_foreign_key =>'notice_id'
  has_and_belongs_to_many :news, :class_name=>"YtwgNews", :join_table=>"user_news", :foreign_key =>'user_id', :association_foreign_key =>'news_id'
  belongs_to :department, :foreign_key=>"department_id"
  def last_login
    self.last_login_time.strftime("%Y-%m-%d %H:%M:%S") rescue nil
  end
  
  #判断用户是否拥有某一种角色
  def is?(role)
    for group in self.groups
      return true if group.name == role
    end
    
    return false
  end
  
  #同区域的用户
  def same_quyu_user
    users = []
    quyu_ids = self.department.quyus.collect{|q| q.id}
    department_ids = DepartmentQuyu.find(:all, :conditions=>"quyu_id in (#{quyu_ids.join(',')})").collect{|d| d.department_id}.uniq
    for department in Department.find(:all, :conditions=>"id in (#{department_ids.join(',')})")
      users << department.users
    end
    users
  end
  
  #归其管理的员工
  def employer
    result = [self]
    deps = Department.find(:all, :conditions=>"parent_id = #{id}")
    for dep in deps
      result += dep.users
    end
    result.uniq
  end
  
  file_column :photo, :magick => {     
          :versions => { "thumb" => "150x150", "medium" => "640x480" }    
        }    
end
