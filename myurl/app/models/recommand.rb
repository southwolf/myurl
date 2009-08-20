class Recommand < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags, :join_table=>"recommand_tag"
  has_many :weburls
  
  def tag_str
    self.tags.collect{|t| "<a href='/main/tag/#{t.id}'>" + t.name + "</a>"}.join(" ")
  end
end
