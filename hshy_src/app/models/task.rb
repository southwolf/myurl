class Task < ActiveRecord::Base
  belongs_to :sender, :class_name=>"YtwgUser", :foreign_key=>"user_id"
  belongs_to :receiver, :class_name=>"YtwgUser", :foreign_key=>"recv_id"
end
