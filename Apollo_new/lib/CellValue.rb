require "Const"

class CellValue
    
    def initialize(valueType, aggType)
        @valueType = valueType
        @aggType = aggType
        if valueType == DOUBLE
            @value = 0
        else
            @value = ""
        end
        @count = 0
    end
    
    def GetType
        @valueType
    end
    
    def AppendValue(value)
        #print "value : #{value}"
        if @valueType == STRING && value.kind_of?(Numeric)
            value = value.to_s
        elsif @valueType==DOUBLE && value.kind_of?(String)
            value = value.to_f
        end
        
        if @valueType == STRING
            @value = value.to_s
        else    #double
            case @aggType
            when AGG_AVERAGE
                @count += 1
                @value += value
            when AGG_COUNT
                @count += 1
            when AGG_MAX
                if @count == 0
                    @value = value
                elsif value > @value
                    @value = value
                end
            when AGG_MIN
                if @count == 0
                    @value = value
                elsif (value < @value)
                    @value = value
                end
            when AGG_LAST_VALUE
                @value = value                
            when AGG_SUM
                @value += value    
            end
        end       
    end
    
    def GetValue
        return @value if @type == STRING
        
        case @type
        when AGG_AVERAGE
            return @value/@count if @count>0
            return 0
        when AGG_COUNT
            return @count
        when AGG_MAX
        when AGG_MIN
        when AGG_LAST_VALUE
        end
        @value
    end
end
