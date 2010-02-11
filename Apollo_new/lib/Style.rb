require "Cell"
require "LogFont"
require "Border"

class CellStyle
    attr_accessor :m_nID
    attr_accessor :m_nHoriAlign
    attr_accessor :m_nVertAlign
    attr_accessor :m_nInputType
    attr_accessor :m_nDataType
    attr_accessor :m_nDecimalDigits
    attr_accessor :m_nTextLength
    attr_accessor :m_clrBackColor
    attr_accessor :m_clrForeColor
    attr_accessor :m_Font
    attr_accessor :m_bShrinkToFit
    attr_accessor :m_bWrapText
    attr_accessor :m_bVarText
    attr_accessor :m_bWidthCheck
    attr_accessor :m_bThousandMark
    attr_accessor :m_bHideFormula
    attr_accessor :m_bProtected
    attr_accessor :m_bShowZero
    attr_accessor :m_bProtected
    attr_accessor :m_Borders  #边界集合,6条
    
    LeftBorder    = 0 
    RightBorder   = 1 
    TopBorder     = 2
    BottomBorder  = 3
    DiagonalLeft  = 4
    DiagonalRight = 5
    
    CtText		=0
    CtNumeric	        =1
    CtBool		=2
    CtDate		=3
    CtPicture	        =4
    CtTime		=5
    CtNone		=6
    
    ItEdit		=0
    ItCheckBox	=1
    ItComboBox	=2
    ItRadioBox	=3
    ItInputEdit	=4
    ItNone		=5
    ItDate		=6
    
    DT_TOP        =   0x00000000
    DT_LEFT       =   0x00000000
    DT_CENTER     =   0x00000001
    DT_RIGHT      =   0x00000002
    DT_VCENTER    =   0x00000004
    DT_BOTTOM     =   0x00000008
    
    
    def initialize
        @m_nID = 0
        @m_nHoriAlign = DT_LEFT
        @m_nVertAlign = DT_VCENTER
        @m_nInputType = ItEdit
        @m_nDataType  = CtNumeric
        @m_nDecimalDigits = 2
        @m_nTextLength = 20
        @m_clrBackColor = 0xffffffff
        @m_clrForeColor = 0
        @m_bShrinkToFit = true
        @m_bWrapText = false
        @m_bVarText = false
        @m_bWidthCheck = false
        @m_bThousandMark = false
        @m_bHideFormula = true
        @m_bProtected = false
        @m_bShowZero = false
        @m_bProtected = false
        @m_Font = LogFont.new
        GetDefaultLogFont(@m_Font)
        
        @m_Borders = Array.new
        for i in 1..6
            @m_Borders << Border.new()
        end
    end
    
    def GetDefaultLogFont(font)
        font.Size = 11
        font.Italic = false
        font.StrikeThrough = false
        font.CharSet = "GB2312_CHARSET"
        font.Bold = false
        font.Underline = false
        font.FontName = "宋体"
    end
    
    def ==(other)
        members = other.instance_variables
        for member in members
            next if member == "@m_nID"
            if self.instance_variable_get(member) != other.instance_variable_get(member)
                return false
            end
        end
        true
    end
    
    def <(other)
        members = other.instance_variables
        for member in members
            if self.instance_variable_get(member) < other.instance_variable_get(member)
                return true
            end
        end
        false
    end
    
    def <=>(other)
        if self <other
            return -1
        elsif self == other
            return 0
        else
            return 1
        end
    end
    
    #获得单元格类型
    def GetDataType
        @m_nDataType
    end
    
    def GetID()
	@m_nID;
    end

    #获得水平对齐方式
    def GetHoriAlign()
	@m_nHoriAlign;
    end

    #获得垂直对齐方式
    def GetVertAlign()
	@m_nVertAlign;
    end

    #获得输入方式，如文本框，下拉框
    def GetInputType()
	@m_nInputType;
    end
 
    #获得小数位数
    def GetDecimal()
	 @m_nDecimalDigits;
    end
		
	#获得文本长度	
    def GetTextLength()
	@m_nTextLength;
    end

    #获得背景色
    def GetBackColor()
	@m_clrBackColor;
    end

    #获得前景色
    def GetForeColor()
	@m_clrForeColor;
    end

    #获得字体
    def GetFont()
	 @m_Font;
    end

    #是否缩小字体填充
    def IsShrinkToFit()
	 @m_bShrinkToFit;
    end

    #是否折行
    def IsWrapText()
	 @m_bWrapText;
    end

    #是否变长文本
    def IsVarText()
	 @m_bVarText;
    end
    
    #是否检查长度
    def IsWidthCheck()
	 @m_bWidthCheck;
    end

    #是否显示千分位
    def IsThousandMark()
	 @m_bThousandMark;
    end

    #是否隐藏公式（已废除）
    def IsHideFormula()
	@m_bHideFormula;
    end
    
    #是否保护
    def IsProtected() 
	@m_bProtected;
    end

    #是否显示0值
    def IsShowZero()
	@m_bShowZero;
    end
		
	#获得左边界	
    def GetLeftBorder()
	@m_Borders[LeftBorder];
    end

    #获得上边界
    def GetTopBorder()
	@m_Borders[TopBorder];
    end

    #获得右边界
    def GetRightBorder()
	@m_Borders[RightBorder];
    end	
	
	#获得底边界
    def GetBottomBorder()
        @m_Borders[BottomBorder];
    end

    def GetDiagLeftBorder()
	@m_Borders[DiagonalLeft];
    end

    def GetDiagRightBorder()
	@m_Borders[DiagonalRight];
    end
    
    #输出XML
    def OutputXML(stylenode)
        stylenode.add_attributes(GetXMLAttrs())
        alignode = stylenode.add_element(Element.new('Alignment'))
        
        aligHash = Hash.new
        aligHash['HoriAlign'] = GetHoriAlign().to_s
        aligHash['VertAlign'] = GetVertAlign().to_s
        if IsShrinkToFit()
            aligHash['ShrinkToFit'] = "1"
        else
            aligHash['ShrinkToFit'] = "0"
        end
        if IsWrapText()
            aligHash['WrapText'] = "1"
        else
            aligHash['WrapText'] = "0"
        end                    
        alignode.add_attributes(aligHash)
        
        bordersnode = stylenode.add_element(Element.new('Borders'))
        
        1.upto(6) do |i|
            border = m_Borders[i-1]
            bordernode = bordersnode.add_element(Element.new('Border'))
            borderattr = Hash.new
            borderattr['Display'] = border.bDisplay.to_s
            borderattr['LineColor'] = "#%06X" % border.LineColor
            borderattr['LineStyle'] = border.LineStyle
            borderattr['LineWidth'] = border.LineWidth
            borderattr['Position']  = (i-1).to_s
            bordernode.add_attributes(borderattr)
        end
        fontnode = stylenode.add_element(Element.new('Font'))
        fontnode.add_attributes(GetFont().GetXMLAttrs())
    end
    
    #获得XML属性,内部调用
    def GetXMLAttrs
        attrs = Hash.new
        attrs["BackColor"] = "#%06X" % GetBackColor().to_s
        attrs["DataType"] = GetDataType().to_s
        attrs["DecimalDigits"] = GetDecimal().to_s
        attrs["ForeColor"] = "#%06X" % GetForeColor().to_s
        attrs["ID"] = GetID().to_s
        attrs["InputType"] = GetInputType().to_s
        if IsWidthCheck()
            attrs["IsCheckWidth"] = "1"
        else
            attrs["IsCheckWidth"] = "0"
        end
        if IsHideFormula()
            attrs["IsHideFormula"] = "1"
        else
            attrs["IsHideFormula"] = "0"
        end
        if IsThousandMark()
            attrs["IsThousandMark"] = "1"
        else
            attrs["IsThousandMark"] = "0"
        end
        if IsShowZero()
            attrs["ShowZero"] = "1"
        else
            attrs["ShowZero"] = "0"
        end
        attrs["TextWidth"] = GetTextLength()
        
        attrs
    end
end
