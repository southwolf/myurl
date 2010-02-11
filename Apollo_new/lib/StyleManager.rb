require "Style"
require "Cell"
require "LogFont"


class StyleManager
    PROP_dataType			 = "a";
    PROP_length				 = "b";
    PROP_checkLength			 = "c";
    PROP_floatCount			 = "d";
    PROP_thousandMark		 = "e";
    PROP_showZero			 = "f";
    PROP_varText				 = "g";
    PROP_fieldName			 = "h";
    PROP_description			 = "i";
    PROP_isStore				 = "j";
    PROP_isConvert			 = "k";
    PROP_isSum				 = "m";
    PROP_inputControl		 = "l";
    PROP_dictionary			 = "n";
    PROP_dictItem			 = "o";
    PROP_halign				 = "p";
    PROP_valign				 = "q";
    PROP_bgcolor				 = "r";
    PROP_fgcolor				 = "s";
    PROP_fillCell			 = "t";
    PROP_wordWrap			 = "u";
    PROP_leftBorder			 = "v";
    PROP_leftBorderWidth		 = "w";
    PROP_rightBorder			 = "x";
    PROP_rightBorderWidth	 = "y";
    PROP_topBorder			 = "z";
    PROP_topBorderWidth		 = "A";
    PROP_bottomBorder		 = "B";
    PROP_bottomBorderWidth	 = "C";
    PROP_borderColor			 = "D";
    PROP_leftBorderColor		 = "E";
    PROP_topBorderColor		 = "F";
    PROP_rightBorderColor	 = "G";
    PROP_bottomBorderColor	 = "H";
    PROP_hideFormula			 = "I";
    PROP_filltype                = "K"
    PROP_aggtype                 = "L"
    
    attr_reader :m_Styles
    
    def initialize
        @m_Styles = Array.new
        @m_nRef = 0
    end
    
    def AddRef
        @m_nRef += 1
    end
    
    def Release
        @m_nRef -= 1
    end
    
    def NewStyle(*args)
        if !args[0]
            style = CellStyle.new
            style.m_nID=-1
        end
        
        if args[0].kind_of?(CellStyle)
            if args[1].kind_of?(Numeric)
                style = args[0]
                style.m_nID = args[1]     
            elsif args[1].kind_of?(Hash)
                style = CellStyle.new
                style.m_nID = -1
                SetStyleAttribute(style, args[1])
                style.m_Font = args[2] if args[2] && args[2].kind_of?(LogFont)
            end
        elsif args[0].kind_of?(Hash) && args[1].kind_of?(LogFont) && args[2].kind_of?(integer)
            style = CellStyle.new
            SetStyleAttribute(style, args[0])
            style.m_Font = args[1] if args[1] && args[1].kind_of?(LogFont)
            style.m_nID = args[2] if args[2] && args[2].kind_of?(Numeric)
        end
        
        if !@m_Styles.include?(style)
            @m_Styles<<style
        end
        
        style
    end
    
    def find(*args)
        if args[0].kind_of?(Numeric)
            for style in @m_Styles
                return style if style.m_nID == args[0]
            end
            return false
        elsif args[0].kind_of?(CellStyle)
            if @Styles.index(args[0])
                return @Styles[@Styles.index(args[0])]
            end
        end
    end
    
    def SetStyleAttribute(style, attrs)
        attrs.each{ |key, value|
            value = attrs[key]
            
            if key == PROP_dataType
                if (value == "text")
		    style.m_nDataType = CCell.ctText;
		elsif(value == "numeric")
                    style.m_nDataType = CCell.ctNumeric;
		elsif(value == "date")
                    style.m_nDataType = CCell.ctDate;
                end
            end
            
            
            style.m_nTextLength = value.to_i if key == PROP_length
            
            style.m_nWidthCheck = value.to_i if key == PROP_checkLength
            
            style.m_nDecimalDigits = value.to_i if key == PROP_floatCount
            
            style.m_bThousandMark = value.to_i if key == PROP_thousandMark
            
            style.m_bShowZero = (value=="true") if key == PROP_showZero
            
            style.m_bVarText = (value == "true") if key == PROP_varText
            
            style.m_nInputType = value.to_i if key == PROP_inputControl
            
            if key == PROP_halign
                style.m_nHoriAlign = DT_LEFT if value == "left"
                style.m_nHoriAlign = DT_CENTER if value == "center"
                style.m_nHoriAlign = DT_RIGHT if value == "right"
            end
            
            if key == PROP_valign
                style.m_nHoriAlign == DT_TOP if value == "top"
                style.m_nHoriAlign == DT_VCENTER if value == "center"
                style.m_nHoriAlign == DT_BOTTOM if value == "bottom"
            end
            
            style.m_clsBackColor = value.to_i if key == PROP_bgcolor
            
            style.m_clsForeColor = value.to_i if key == PROP_fgcolor
            
            style.m_bShrinkToFit = (value=="true") if key == PROP_fillCell
            
            style.m_bWrapText = (value == "true") if key == PROP_wordWrap
            
            if(key == PROP_leftBorderColor) 
                border = style.m_Borders[CellStyle.LeftBorder];
                border.LineColor = value.to_i
            elsif(key == PROP_leftBorderWidth)
                border = style.m_Borders[CellStyle.LeftBorder];
                border.LineWidth = value.to_i
            elsif(key == PROP_leftBorder)
                border = style.m_Borders[CellStyle.LeftBorder];
                border.bDisplay = changebool(value)        
            elsif(key == PROP_rightBorderColor)
                border = style.m_Borders[CellStyle.RightBorder];
                border.LineColor = value.to_i           
            elsif(key == PROP_rightBorderWidth)
                border = style.m_Borders[CellStyle.RightBorder];
                border.LineWidth = value.to_i         
            elsif(key == PROP_rightBorder)
                border = style.m_Borders[CellStyle.RightBorder];
                border.bDisplay = changebool(value)         
            elsif(key == PROP_topBorderColor)
                border = style.m_Borders[CellStyle.TopBorder];
                border.LineColor = value.to_i            
            elsif(key == PROP_topBorderWidth)
                border = style.m_Borders[CellStyle.TopBorder];
                border.LineWidth = value.to_i          
            elsif(key == PROP_topBorder)
                border = style.m_Borders[CellStyle.TopBorder];
                border.bDisplay = changebool(value)            
            elsif(key == PROP_bottomBorderColor)
                border = style.m_Borders[CellStyle.BottomBorder];
                border.LineColor = value.to_i
            elsif(key == PROP_bottomBorderWidth)
                border = style.m_Borders[CellStyle.BottomBorder];
                border.LineWidth = value.to_i   
            elsif(key == PROP_bottomBorder)
                border = style.m_Borders[CellStyle.BottomBorder];
                border.bDisplay = changebool(value)         
            elsif(key == PROP_borderColor)
                    for i in 0..5
                            border = style.m_Borders[i];
                            border.LineColor = value.to_i
                    end
            end
        }
    end
    
    def GetStyleAttribute(cell, key)
        style = cell.GetStyle()
        return  style.m_nDataType if key == PROP_dataType
        return  style.m_nTextLength  if key == PROP_length
        return  style.m_nWidthCheck  if key == PROP_checkLength
        return  style.m_nDecimalDigits if key == PROP_floatCount
        return  style.m_bThousandMark  if key == PROP_thousandMark
        return  style.m_bShowZero  if key == PROP_showZero
        return  style.m_bVarText  if key == PROP_varText
        return  style.m_nInputType  if key == PROP_inputControl
        return  style.m_nHoriAlign if key == PROP_halign
        return  style.m_nHoriAlign if key == PROP_valign
        return  style.m_clsBackColor if key == PROP_bgcolor
        return  style.m_clsForeColor if key == PROP_fgcolor
        return  style.m_bShrinkToFit if key == PROP_fillCell
        return  style.m_bWrapText if key == PROP_wordWrap
        if(key == PROP_leftBorderColor) 
            border = style.m_Borders[CellStyle.LeftBorder];
            return border.LineColor
        elsif(key == PROP_leftBorderWidth)
            border = style.m_Borders[CellStyle.LeftBorder];
            return border.LineWidth
        elsif(key == PROP_leftBorder)
            border = style.m_Borders[CellStyle.LeftBorder];
            return border.bDisplay    
        elsif(key == PROP_rightBorderColor)
            border = style.m_Borders[CellStyle.RightBorder];
            return border.LineColor = value.to_i           
        elsif(key == PROP_rightBorderWidth)
            border =  style.m_Borders[CellStyle.RightBorder];
            return border.LineWidth
        elsif(key == PROP_rightBorder)
            border =  style.m_Borders[CellStyle.RightBorder];
            return border.bDisplay   
        elsif(key == PROP_topBorderColor)
            border =  style.m_Borders[CellStyle.TopBorder];
            return border.LineColor   
        elsif(key == PROP_topBorderWidth)
            border =  style.m_Borders[CellStyle.TopBorder];
            return border.LineWidth
        elsif(key == PROP_topBorder)
            border =  style.m_Borders[CellStyle.TopBorder];
            return border.bDisplay         
        elsif(key == PROP_bottomBorderColor)
            border =  style.m_Borders[CellStyle.BottomBorder];
            return border.LineColor
        elsif(key == PROP_bottomBorderWidth)
            border =  style.m_Borders[CellStyle.BottomBorder];
            return border.LineWidth
        elsif(key == PROP_bottomBorder)
            border =  style.m_Borders[CellStyle.BottomBorder];
            return border.bDisplay
        elsif (key == PROP_filltype)
            #return cell.attribute / 0x8000
            if (cell.IsEffective() && cell.IsStore())
                flag= cell.attribute & 0x00030000;
                value = flag >> 16
                return value
            else
                return FILL_NONE
            end            
        elsif (key == PROP_aggtype)
            flag = cell.attribute & 0x007C0000
            value = flag / 0x20000
            if(value<AGG_SUM || value>AGG_LAST_VALUE)
		return AGG_SUM
            end
	return value;
        end
    end
    
    def DestroyAllStyles
        m_Styles.clear
    end
    
    def ReNumber
        index = 0
        for style in m_Styles
            style.m_nID = index
            index += 1
        end
    end
    
    #释放无用单元格风格,styles是一个array
    def PurgeStyles(styles)
        for style in styles
            styles.delete(style) if m_Styles.include?(style)
        end
    end
    
private
    #将"true","false"转换成true, false
    def changebool(str)
        if str == "true"
            return true
        else
            return false
        end
    end
end
