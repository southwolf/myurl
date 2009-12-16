class Software < ActiveRecord::Base
  has_many :bugs, :class_name=>"SoftwareBug"
end
