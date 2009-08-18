class User < ActiveRecord::Base
  has_many :catalogs
  
  def adopt_count
    self.adopt_count || 0
  end
end
