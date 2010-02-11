class Unit < ActiveRecord::Base
  set_primary_key :unitid
  
  def <=>(other)
    return  unitid[unitid.length-1, 1] <=> other.unitid[unitid.length-1, 1] if unitid[unitid.length-1, 1] != other.unitid[unitid.length-1, 1]
    return  unitid <=> other.unitid
  end
end
