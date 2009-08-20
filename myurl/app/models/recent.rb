class Recent < ActiveRecord::Base
  belongs_to :weburl, :foreign_key=>"site_id"
  belongs_to :recommand, :foreign_key=>"site_id"
  belongs_to :user
end
