require 'composite_primary_keys'

class UnitFMTableData < ActiveRecord::Base
  set_primary_key :unitid
  acts_as_tree :foreign_key =>"p_parent", :order=>"unitid"
  
  attr_accessor :attributes
  
  def <=>(other)
    return  unitid[unitid.length-1, 1] <=> other.unitid[unitid.length-1, 1] if unitid[unitid.length-1, 1] != other.unitid[unitid.length-1, 1]
    return  unitid <=> other.unitid
  end
  
  def read_attribute(attr_name)
        attr_name = attr_name.to_s
        if @attributes.keys.include?(attr_name) && column_for_attribute(attr_name).type == :datetime
          value = super
          if value.kind_of?(Time)
            value = value.strftime("%Y-%m-%d")
            return value
          end
        end
        
        return @attributes[attr_name]
  end
  
  #判断一条记录是不是另一条记录的子节点
  def is_descendant_of(other)    
    if self["p_parent"].to_s == other.unitid.to_s
      return true
    end

    return false if parent == nil
    return parent.is_descendant_of(other)
  end
  
  #写这个函数是因为ActiveRecord有一个缺陷。表每个字段的类型存放在类中，不是存放在实例中
  def get_typed_value()
    @attributes.each{|key, strvalue|
      if self[key].kind_of?(Time)
      	@attributes[key] = self[key].strftime("%Y-%m-%d")
      else
      	@attributes[key] = self[key]
      end
    }
  end
  
  #因为ActiveRecord有一个缺陷,主关键字在赋值后不得改变，先调用Bak后就可以改变
  def Bak
    @_unitid = unitid
  end
  
  #重载父类的update函数，原因同上
  def update
      @_unitid = @_unitid || unitid
      
        setstr = "SET "
        @attributes.each{|key, value|
          if value.kind_of?(Numeric)
            setstr += key + "=" + "#{value}, "
          elsif value.kind_of?(NilClass)
            setstr += key + "= null, "
          else
            setstr += key + "=" + "'#{value}', "
          end
        }
        setstr = setstr[0, setstr.length-2]
        
        connection.update(

          "UPDATE #{self.class.table_name} " +
          setstr +
          " WHERE unitid='#{@_unitid}' ",
          "#{self.class.name} Update"
        )

        return true
  end
end