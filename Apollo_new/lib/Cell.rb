require "Size"

class CCell    
    TC_CF_EFFECTIVE   = 0x00000001
    TC_CF_STORE       = 0x00000002
    TC_CF_PRECISION	= 0x00000004		
    TC_CF_SUM	        = 0x00000008
    TC_CF_KEY		= 0x00000010			
    TC_CF_ALLOWNULL	= 0x00000020
    TC_CF_SERIAL	= 0x00010000
    
    
    
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
    
    attr_reader :attribute
    
    def initialize(*args)
        if args.length == 0
            @name = ""
            @text = ""
            @m_csChineseName = ""
            @m_csRemark = ""            
            @m_szCoveredBox = CSize.new(1, 1)
            @m_wKeyOrder = -1
            @m_csDictName = ""
            @attribute = 0x0
            @attribute |= TC_CF_EFFECTIVE
            @attribute |= TC_CF_ALLOWNULL
            @attribute |= TC_CF_SUM
            
            @m_pStyle = nil
        else
            members = args[0].instance_variables
            for member in members
                self.instance_variable_set(member, other.instance_variable_get(member))
            end
        end
    end
    
    #拷贝单元格值
    def self=(other)
        @text = other.GetText()
    end
    
    #def +(other)
    #end
    
    #复制单元格，包括所有属性和值
    def copy(other)
        @attribute = other.attribute
        @name = other.GetName()
        @text = other.GetText()
        @m_csChineseName = other.GetDescription()
        @m_csRemark = other.GetRemark()
        @m_wKeyOrder = other.GetKeyOrder()
        @m_csDictName = other.GetDictName()
        @m_pStyle = other.GetStyle()
        @m_szCoveredBox.cx = other.GetCoveredScale().cx
        @m_szCoveredBox.cy = other.GetCoveredScale().cy
    end
    
    #获得属性
    def GetAttributes()
        @attribute
    end
    
    #获得运行时属性
    #dwFlag : 标志
    def GetRunAttribute(dwFlag)
        @m_wRunFlag & dwFlag
    end
    
    #判断类型是否为数值型
    def IsNumeric
        @m_pStyle.GetDataType == CtNumeric
    end
    
    #判断类型是否为日期型
    def IsDate
        @m_pStyle.GetDataType == CtDate
    end
    
    #判断类型是否为字符串型
    def IsText
        @m_pStyle.GetDataType == CtText
    end
    
    #判断类型是否为图片型
    def IsPicture
        @m_pStyle.GetDataType == CtPicture
    end
    
    #判断单元格是否有效，合并单元格的时候被覆盖的单元格无效，其余单元格都有效
    def IsEffective
        result = (@attribute & TC_CF_EFFECTIVE) != 0
    end
    
    #判断类型是否只读
    def IsReadOnly
        readOnly = 0x40
        if (GetStyle().IsProtected() || @attribute&readOnly !=0)
            return true
        else
            return false
        end
    end
    
    #是否显示千分位
    def IsThousand
        GetStyle().IsThousandMark
    end
    
    #是否缩小字体填充
    def IsShrinkToFit
        GetStyle().IsShrinkToFit
    end
    
    #是否进行精度转换
    def IsConvert
        (@attribute & TC_CF_PRECISION )!= 0
    end
    
    #是否进行等宽检查
    def IsCheckWidth
        GetStyle().IsWidthCheck() && (IsText() && !IsVarText()	|| IsNumeric())
    end
    
    #是否自动折行
    def IsWordBreak
        GetStyle().IsWrapText
    end
    
    #是否显示0值
    def IsShowZero
        GetStyle().IsShowZero
    end
    
    
    #def IsFieldName
    #    0
    #end
    
    #是否存储到数据库
    def IsStore
        (@attribute & TC_CF_STORE)!= 0
    end
    
    #是否进行精度转换
    def IsPrecision
        @attribute & TC_CF_PRECISION
    end
    
    #是否参与汇总
    def IsSum
        @attribute & TC_CF_SUM != 0
    end
    
    #是否变长文本
    def IsVarText
        GetStyle().IsVarText
    end
    
    #是否自动运算
    def IsNoEdit
        IsReadOnly() || GetRunAttribute(TC_CF_CALC_CELL)
    end
    
    #是否参与汇总
    def IsSumable
        IsStore() && IsNumeric() && IsSum()
    end
    
    #是否采用下拉框进行录入
    def IsDictionInputType
        IsStore() && IsText() && GetStyle().GetInputType() == ItComboBox && !@dictName.empty?
    end
    
    #获得字体
    def GetFont
        GetStyle().GetFont()
    end
    
    #获得背景色
    def GetBackColor
        GetStyle().GetBackColor()
    end
    
    #获得字体颜色
    def GetForeColor
        GetStyle().GetForeColor()
    end
    
    #获得水平对齐方式
    def GetHoriAlign
        GetStyle().GetHoriAlign()
    end
    
    #获得垂直对齐方式
    def GetVertAlign
        GetStyle().GetVertAlign()
    end
    
    #获得线条颜色
    def GetLineColor
        GetStyle().GetLeftBorder().LineColor
    end
    
    #获得单元格数值类型：数字，字符串，日期，图片
    def GetDataType
        GetStyle().GetDataType()
    end
    
    #获得小数个数
    def GetDecimal
        GetStyle().GetDecimal()
    end
    
    #获得文本长度，默认20
    def GetTextWidth
        GetStyle().GetTextLength()
    end
    
    #获得输入方式
    def GetInputType
        GetStyle().GetInputType()
    end
    
    #获得单元格某种属性，如TC_CF_EFFECTIVE，返回true or false
    def GetAttribute(dwFlag)
	   if (@attribute & dwFlag) == 0
            return false
	   else
            return true
	   end
    end
    
    #设置单元格某种属性，如TC_CF_EFFECTIVE
    def SetAttribute(dwFlag, bTrue)
      if(bTrue)
	     @attribute |= dwFlag   
      else
	     @attribute &= ~dwFlag 
	  end
    end
    
    #设置单元格风格
    def SetStyle(style)
        @m_pStyle = style
    end
    
    #获得单元格风格
    def GetStyle
        @m_pStyle
    end
    
    #设置单元格文本值
    def SetText(text)
        @text = text
    end
    
    #返回单元格文本值
    def GetText
        @text
    end
    
    #根据单元格类型返回值
    def GetTypedValue
        if GetDataType() == CtText
            @text
        elsif GetDataType() == CtNumeric
            @text.to_f
        end
    end
    
    #设置单元格名称
    def SetName(name)
        @name = name
    end
    
    #获得单元格名称
    def GetName
        @name
    end
    
    #设置单元格描述
    def SetDescription(desc)
        @m_csChineseName = desc
    end
    
    #获得单元格描述
    def GetDescription
        @m_csChineseName
    end
    
    #已失效
    def SetRemark(remark)
        @m_csRemark = remark
    end
    
    #已失效
    def GetRemark
        @m_csRemark
    end
    
    #设置单元格合并跨度
    #sz : CSize对象
    def SetCoveredScale(sz)
	  @m_szCoveredBox = sz;
    end
    
    #获得单元格合并跨度
    def GetCoveredScale
        if(IsEffective())
	    return @m_szCoveredBox
        end
	    #size = CSize.new
	    return CSize.new(1,1)
    end
    
    def SetMappingBox(sz)
        @m_szCoveredBox = sz
    end
    
    def GetMappingBox
        if !IsEffective()
            return @m_szCoveredBox
        end
        return CSize.new(0, 0)
    end
    
    #已失效
    def SetKeyOrder(wOrder)
        @m_wKeyOrder = wOrder
    end
    
    #已失效
    def GetKeyOrder
        @m_wKeyOrder
    end
    
    #设置单元格代码字典
    def SetDictName(dict)
        @m_csDictName = dict
    end
    
    #获得单元格代码字典
    def GetDictName
        @m_csDictName
    end
    
    def OutputXML(node, index)
        attr = Hash.new
        attr['Description'] = GetDescription()
        attr['DictDisplayMode'] = "1"       #要改
        attr['DictName'] = GetDictName()
        attr['Flags'] = (@attribute >> 16).to_s
        attr['Index'] = index.to_s
        
        if IsConvert()
            attr['IsConvertPrecision'] = "1"
        else
            attr['IsConvertPrecision'] = "0"
        end
        
        if IsStore()
            attr['IsStoreDB'] = "1"
        else
            attr['IsStoreDB'] = "0"
        end
        
        if IsSum()
            attr['IsSum'] = "1"
        else
            attr['IsSum'] = "0"
        end
        attr['MergeAcross'] = GetCoveredScale().x
        attr['MergeDown'] = GetCoveredScale().y
        attr['Name'] = EncodeUtil.change("UTF-8", "GB2312", GetName())            
        attr['ReadOnly'] = IsReadOnly().to_s
        attr['StyleID'] = GetStyle().GetID()
        node.add_attributes(attr)
        
        node.add_element(Element.new('Data')).text = EncodeUtil.change("UTF-8", "GB2312", GetText())            
    end
end