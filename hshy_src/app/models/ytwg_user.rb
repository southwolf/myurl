class YtwgUser < ActiveRecord::Base
  has_and_belongs_to_many :groups, :class_name=>"YtwgGroup", :join_table=>"ytwg_usergroup", :foreign_key =>'user_id', :association_foreign_key =>'group_id'
#  has_and_belongs_to_many :votes, :class_name=>"Vote", :join_table=>"vote_user", :foreign_key =>'user_id', :association_foreign_key =>'vote_id'
  has_and_belongs_to_many :notices, :class_name=>"Notice", :join_table=>"user_notice", :foreign_key =>'user_id', :association_foreign_key =>'notice_id'
  has_and_belongs_to_many :news, :class_name=>"YtwgNews", :join_table=>"user_news", :foreign_key =>'user_id', :association_foreign_key =>'news_id'
  belongs_to :department, :foreign_key=>"department_id"
  def last_login
    self.last_login_time.strftime("%Y-%m-%d %H:%M:%S") rescue nil
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
