class Picture < ActiveRecord::Base
  belongs_to :user, :class_name=>"YtwgUser", :foreign_key => "user_id"
  file_column :path, :magick => {     
          :versions => { "thumb" => "150x150", "medium" => "640x480" }    
        }    
end
