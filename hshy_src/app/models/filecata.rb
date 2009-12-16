class Filecata < ActiveRecord::Base
  has_many :documentfiles, :foreign_key=>"cata_id"
end
