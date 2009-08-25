class User < ActiveRecord::Base
  has_many :catalogs
  has_many :hots
  
  def adopt_count
    self.adopt_count || 0
  end
end
