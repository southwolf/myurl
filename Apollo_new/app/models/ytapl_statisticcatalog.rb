class YtaplStatisticcatalog < ActiveRecord::Base
    set_table_name :ytapl_statisticcatalog
    acts_as_tree :order=>"id"
    
    has_many :reports, :class_name=>"YtaplStatistic", :foreign_key => "cata_id"
end
