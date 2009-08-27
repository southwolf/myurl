class Weburl < ActiveRecord::Base
  def adopt_count
    self.adopt_count || 0
  end
  
  def address
    if self.index('http') == nil
      return "http://" + address
    end
    
    return self
  end
end
