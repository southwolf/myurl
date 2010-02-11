require "EncodeUtil"

class LogFont
    attr_accessor :Size, :FontName, :Bold, :CharSet, :Underline, :StrikeThrough, :Italic
    def initialize
        @Size = 11
        @FontName = "serif"
        @Bold = false
        @CharSet="GB2312_CHARSET"
        @Underline = false
        @StrikeThrough = false
        @Italic = false
    end
    
    def ==(other)
        members = other.instance_variables
        for member in members
            a = self.instance_variable_get(member)
            if self.instance_variable_get(member) != other.instance_variable_get(member)
                return false
            end
        end
        true
    end
    
    def GetXMLAttrs
        attrs = Hash.new
        if @Bold
            attrs['Bold'] = "1"
        else
            attrs['Bold'] = "0"
        end
        
        attrs['CharSet'] = @CharSet
        attrs['FontName'] = @FontName
        if @Italic
            attrs['Italic'] = '1'
        else
            attrs['Italic'] = '0'
        end
        if @StrieThrough
            attrs['StrikeThrough'] = '1'
        else
            attrs['StrikeThrough'] = '0'
        end
        if @Underline
            attrs['Underline'] = '1'
        else
            attrs['Underline'] = '0'
        end
        attrs['Size'] = @Size.to_s
        attrs
    end
end