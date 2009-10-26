class User < ActiveRecord::Base
  belongs_to :kaixinuser
  has_many :archievements
end
