class Weburl < ActiveRecord::Base
  def adopt_count
    self.adopt_count || 0
  end
  
  def address_real
    if self.address && self.address.index('http') == nil
      return "http://" + self.address
    end
    
    return self.address
  end
end
