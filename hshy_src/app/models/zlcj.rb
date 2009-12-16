class Zlcj < ActiveRecord::Base
  def page
    count = Zlcj.count("id >= #{self.id}")
    p1  = count / 20 
    p1 += 1 if count % 20 > 0
    return p1
  end
end
