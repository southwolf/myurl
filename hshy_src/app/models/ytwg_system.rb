class YtwgSystem < ActiveRecord::Base
  file_column :logo, :magick => {     
          :versions => { "thumb" => "50x50"}    
        }    
end
