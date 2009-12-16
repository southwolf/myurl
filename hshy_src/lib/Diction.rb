class Diction
    attr_accessor :Name, :ID, :Length, :OnlyLeaf, :Levels
    #attr_reader :m_mapDiction
    
    def initialize(*args)
        @m_mapDiction = Hash.new
        @m_RootSet = Array.new
        if args.length == 0
            @Name = ""
            @ID = ""
            @Length = 1
            @OnlyLeaf = true
        elsif args.length = 2
            @ID = args[0] if args[0].kind_of?(Numeric)
            @Name = args[1] if args[1].kind_of?(Numeric)
            @Length = 0
            @OnlyLeaf = true
            @Levels = ""
        end
    end
    
    def GetItemName(code)
        if @m_mapDiction[code]
            @m_mapDiction[code].to_s
        else
            ""
        end
    end
    
    def GetItemCode(text)
        @m_mapDiction.each{|key, value| return key if text == value}
        ""
    end
    
    def GetSize
        @m_mapDiction.length
    end
    
    #���ظ��ڵ㣬����������array
    def GetRootItems
      levels = @Levels.split(',')
      if levels.size > 0
        zero_len = @Length - levels[0].to_i
      else
        return @m_mapDiction.keys
      end
      
      roots = Array.new
      @m_mapDiction.each{|key, value|
          roots << key if key =~ /0{#{zero_len}}$/  
      }
      roots.sort
    end
    
    def Find(partCode)
        @m_mapDiction.each{|key, value|
            return key if key.sub(partCode) == 0
        }
        ""
    end
    
    def GetAllItems
        @m_mapDiction.dup
    end
    
    def GetChildren(parent)
      levels = @Levels.split(',')
      levels.collect!{|l| l.to_i}
      for level in levels
        next if level==0
        if parent =~ /(\w{#{@Length-level}})0{#{level}}/
          pre = $1
          children = Array.new
          @m_mapDiction.each{|key, value|
            children << key if key =~ /^#{pre}/  && key != parent
          }
          return children.sort
          break
        end
      end
      
      []
    end
    
    def AddDictItem(code, mean)
        @m_mapDiction[code] = mean
    end
    
    #items��һ��hash
    def AddDictItems(items)
        items.each{|key, value|
            @m_mapDiction[key] = value
        }
    end
    
    def DeleteItem(code)
        @m_mapDiction.delete(code)
    end
    
    def ClearDictItems
        @m_mapDiction.clear
    end
    
    def OutputXML(dictnode)
        attr = Hash.new
        attr['ID'] = @ID
        if @OnlyLeaf
            attr['ID'] = 1
        else
            attr['ID'] = 0
        end
        attr['Length'] = @Length
        attr['Levels'] = @Levels
        attr['Name'] = @Name
        if @OnlyLeaf
          attr['IsLeaf'] = '1'
        else
          attr['IsLeaf'] = '0'
        end
        dictnode.add_attributes(attr)
        @m_mapDiction.each { |key, value|
            itemnode = dictnode.add_element(Element.new('Item'))
            itemnode.add_attributes({'Code' => key, 'Mean' => value})
        }
    end
end


class DictionFactory
    def initialize
        #{id => Diction}
        @m_mapDictions = Hash.new
    end
    
    def GetDiction(name)
        @m_mapDictions.each{|key, value|
            return value if value.GetName == name
        }
        nil
    end
    
    def GetDictionByID(id)
        @m_mapDictions[id]
    end
    
    #����array
    def GetAllDictions
        result = Array.new
        @m_mapDictions.each{|key, value|
            result<<value
        }
        result
    end
    
    def AddDiction(dict)
        @m_mapDictions[dict.ID] = dict
    end
    
    def DeleteDiction(id)
        @m_mapDictions.each{|key, value|
            if key == id
                @m_mapDictions.delete(key)
                return
            end
        }
    end
    
    def ClearAll
        @m_mapDictions.clear
    end
    
    def CreateDiction
        Diction.new
    end
end
