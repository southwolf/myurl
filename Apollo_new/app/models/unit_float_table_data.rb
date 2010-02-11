require 'composite_primary_keys'

class UnitFloatTableData < ActiveRecord::Base
  set_primary_keys :unitid, :tasktimeid, :float_id
  
  attr_accessor :attributes
  
  #写这个函数是因为ActiveRecord有一个缺陷。表每个字段的类型存放在类中，不是存放在实例中
  def get_typed_value()
    @attributes.each{|key, strvalue|
      if column = column_for_attribute(key)
        @attributes[key] = column.type_cast(self[key])
      end
    }
  end
  
  def read_attribute(attr_name)
        attr_name = attr_name.to_s
#        begin
#        YtLog.info attr_name
#        if @attributes.keys.include?(attr_name) && column_for_attribute(attr_name).type == :datetime
#          value = super
#          if value.kind_of?(Time)
#            value = value.strftime("%Y-%m-%d")
#            return value
#          end
#        end
#        rescue
#        end
        
        return @attributes[attr_name]
  end
  
  #重载父类的update函数，原因同上
  def update
        setstr = "SET "
        @attributes.each{|key, value|
          if value.kind_of?(Numeric)
            setstr += key + "=" + "#{value},"
          elsif value.kind_of?(NilClass)
            setstr += key + "=null,"
          else
            setstr += key + "=" + "'#{value}',"
          end
        }
        setstr = setstr[0, setstr.length-1]
  
        connection.update(

          "UPDATE #{self.class.table_name} " +
          setstr +
          " WHERE unitid='#{unitid}' and tasktimeid=#{tasktimeid} and float_id=#{float_id}",
          "#{self.class.name} Update"
        )
        return true
  end
end

