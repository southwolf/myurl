class Photo < ActiveRecord::Base
  belongs_to :house, :class_name=>"House", :foreign_key => "house_id"
  
  file_column :path, :magick => {     
          :versions => { "thumb" => "150x150", "medium" => "640x480" }    
        }    
end
