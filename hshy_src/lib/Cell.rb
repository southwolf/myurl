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
    ItButton    =7
    
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
    
    #������Ԫ��ֵ
    def self=(other)
        @text = other.GetText()
    end
    
    #def +(other)
    #end
    
    #���Ƶ�Ԫ�񣬰����������Ժ�ֵ
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
    
    #�������
    def GetAttributes()
        @attribute
    end
    
    #�������ʱ����
    #dwFlag : ��־
    def GetRunAttribute(dwFlag)
        @m_wRunFlag & dwFlag
    end
    
    #�ж������Ƿ�Ϊ��ֵ��
    def IsNumeric
        @m_pStyle.GetDataType == CtNumeric
    end
    
    #�ж������Ƿ�Ϊ������
    def IsDate
        @m_pStyle.GetDataType == CtDate
    end
    
    #�ж������Ƿ�Ϊ�ַ�����
    def IsText
        @m_pStyle.GetDataType == CtText
    end
    
    #�ж������Ƿ�ΪͼƬ��
    def IsPicture
        @m_pStyle.GetDataType == CtPicture
    end
    
    #�жϵ�Ԫ���Ƿ���Ч���ϲ���Ԫ���ʱ�򱻸��ǵĵ�Ԫ����Ч�����൥Ԫ����Ч
    def IsEffective
        result = (@attribute & TC_CF_EFFECTIVE) != 0
    end
    
    #�ж������Ƿ�ֻ��
    def IsReadOnly
        readOnly = 0x40
        if (GetStyle().IsProtected() || @attribute&readOnly !=0)
            return true
        else
            return false
        end
    end
    
    #�Ƿ���ʾǧ��λ
    def IsThousand
        GetStyle().IsThousandMark
    end
    
    #�Ƿ���С�������
    def IsShrinkToFit
        GetStyle().IsShrinkToFit
    end
    
    #�Ƿ���о���ת��
    def IsConvert
        (@attribute & TC_CF_PRECISION )!= 0
    end
    
    #�Ƿ���еȿ���
    def IsCheckWidth
        GetStyle().IsWidthCheck() && (IsText() && !IsVarText()	|| IsNumeric())
    end
    
    #�Ƿ��Զ�����
    def IsWordBreak
        GetStyle().IsWrapText
    end
    
    #�Ƿ���ʾ0ֵ
    def IsShowZero
        GetStyle().IsShowZero
    end
    
    
    #def IsFieldName
    #    0
    #end
    
    #�Ƿ�洢�����ݿ�
    def IsStore
        (@attribute & TC_CF_STORE)!= 0
    end
    
    #�Ƿ���о���ת��
    def IsPrecision
        @attribute & TC_CF_PRECISION
    end
    
    #�Ƿ�������
    def IsSum
        @attribute & TC_CF_SUM != 0
    end
    
    #�Ƿ�䳤�ı�
    def IsVarText
        GetStyle().IsVarText
    end
    
    #�Ƿ��Զ�����
    def IsNoEdit
        IsReadOnly() || GetRunAttribute(TC_CF_CALC_CELL)
    end
    
    #�Ƿ�������
    def IsSumable
        IsStore() && IsNumeric() && IsSum()
    end
    
    #�Ƿ�������������¼��
    def IsDictionInputType
        IsStore() && IsText() && GetStyle().GetInputType() == ItComboBox && !@dictName.empty?
    end
    
    #�������
    def GetFont
        GetStyle().GetFont()
    end
    
    #��ñ���ɫ
    def GetBackColor
        GetStyle().GetBackColor()
    end
    
    #���������ɫ
    def GetForeColor
        GetStyle().GetForeColor()
    end
    
    #���ˮƽ���뷽ʽ
    def GetHoriAlign
        GetStyle().GetHoriAlign()
    end
    
    #��ô�ֱ���뷽ʽ
    def GetVertAlign
        GetStyle().GetVertAlign()
    end
    
    #���������ɫ
    def GetLineColor
        GetStyle().GetLeftBorder().LineColor
    end
    
    #��õ�Ԫ����ֵ���ͣ����֣��ַ��������ڣ�ͼƬ
    def GetDataType
        GetStyle().GetDataType()
    end
    
    #���С������
    def GetDecimal
        GetStyle().GetDecimal()
    end
    
    #����ı����ȣ�Ĭ��20
    def GetTextWidth
        GetStyle().GetTextLength()
    end
    
    #������뷽ʽ
    def GetInputType
        GetStyle().GetInputType()
    end
    
    #��õ�Ԫ��ĳ�����ԣ���TC_CF_EFFECTIVE������true or false
    def GetAttribute(dwFlag)
	   if (@attribute & dwFlag) == 0
            return false
	   else
            return true
	   end
    end
    
    #���õ�Ԫ��ĳ�����ԣ���TC_CF_EFFECTIVE
    def SetAttribute(dwFlag, bTrue)
      if(bTrue)
	     @attribute |= dwFlag   
      else
	     @attribute &= ~dwFlag 
	  end
    end
    
    #���õ�Ԫ����
    def SetStyle(style)
        @m_pStyle = style
    end
    
    #��õ�Ԫ����
    def GetStyle
        @m_pStyle
    end
    
    #���õ�Ԫ���ı�ֵ
    def SetText(text)
        @text = text
    end
    
    #���ص�Ԫ���ı�ֵ
    def GetText
        @text
    end
    
    #���ݵ�Ԫ�����ͷ���ֵ
    def GetTypedValue
        if GetDataType() == CtText
            @text
        elsif GetDataType() == CtNumeric
            @text.to_f
        end
    end
    
    #���õ�Ԫ������
    def SetName(name)
        @name = name
    end
    
    #��õ�Ԫ������
    def GetName
        @name
    end
    
    #���õ�Ԫ������
    def SetDescription(desc)
        @m_csChineseName = desc
    end
    
    #��õ�Ԫ������
    def GetDescription
        @m_csChineseName
    end
    
    #��ʧЧ
    def SetRemark(remark)
        @m_csRemark = remark
    end
    
    #��ʧЧ
    def GetRemark
        @m_csRemark
    end
    
    #���õ�Ԫ��ϲ����
    #sz : CSize����
    def SetCoveredScale(sz)
	  @m_szCoveredBox = sz;
    end
    
    #��õ�Ԫ��ϲ����
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
    
    #��ʧЧ
    def SetKeyOrder(wOrder)
        @m_wKeyOrder = wOrder
    end
    
    #��ʧЧ
    def GetKeyOrder
        @m_wKeyOrder
    end
    
    #���õ�Ԫ������ֵ�
    def SetDictName(dict)
        @m_csDictName = dict
    end
    
    #��õ�Ԫ������ֵ�
    def GetDictName
        @m_csDictName
    end
    
    def OutputXML(node, index)
        attr = Hash.new
        attr['Description'] = GetDescription()
        attr['DictDisplayMode'] = "1"       #Ҫ��
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