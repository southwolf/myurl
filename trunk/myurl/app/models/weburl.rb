class Weburl < ActiveRecord::Base
  def adopt_count
    self.adopt_count || 0
  end
end
