class Phonecontract < ActiveRecord::Base
  belongs_to :unit
  belongs_to :user, :class_name=>"YtwgUser", :foreign_key => "user_id"

end
