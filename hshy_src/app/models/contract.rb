class Contract < ActiveRecord::Base
  belongs_to :department
  belongs_to :user, :class_name => "YtwgUser", :foreign_key=>"user_id"
  
  def page
    count = Contract.count("department_id = #{self.department_id} and id >= #{self.id} and status=#{self.status}")
    p1  = count / 20 
    p1 += 1 if count % 20 > 0
    return p1
  end
end
