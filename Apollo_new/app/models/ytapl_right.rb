class YtaplRight < ActiveRecord::Base
  def desc
    self.memo
  end
  
  def desc=(other)
    self.memo = other
  end
end
