class Recommand < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :weburls
end
