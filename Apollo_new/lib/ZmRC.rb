class ZmRC
    TC_RCF_EMPTY	= 0x00000001
    TC_RCF_HIDE		= 0x00000002
    TC_RCF_FLOATTEMPL	= 0x00000004
    
    attr_reader :m_nOrder, :m_nWidth, :m_dwFlag
    
    def initialize(*args)
        @m_nOrder = 0
        @m_nWidth = 0
        @m_dwFlag = 0x0
        if args.length ==1
        end
    end
    
    def SetOrder(nOrder)
        @m_nOrder = nOrder
    end
    
    def GetOrder
        return @m_nOrder
    end
    
    def self=(other)
        @m_dwFlag = other.m_dwFlag
        @m_nOrder = other.m_nOrder
        @m_nWidth = other.m_nWidth
    end
    
    def GetAttribute(dwFlag)
        result = @m_dwFlag & dwFlag;
        result
    end
    
    def SetAttribute(dwFlag, bTrue)
        if bTrue
            @m_dwFlag |= dwFlag
        else
            @m_dwFlag &= ~dwFlag;
        end
    end
    
    def IsFloatTempl
        GetAttribute(TC_RCF_FLOATTEMPL) != 0 && !IsEmpty()
    end
    
    def IsHide
        GetAttribute(TC_RCF_HIDE) != 0
    end
    
    def SetHide(bTrue)
        SetAttribute(TC_RCF_HIDE, bTrue)
    end
    
    def IsEmpty
        return GetAttribute(TC_RCF_EMPTY) != 0
    end
    
    def SetEmpty(bTrue)
        SetAttribute(TC_RCF_EMPTY, bTrue)
    end
    
    def GetRowHeight
        return @m_nWIdth
    end
    
    def SetRowHeight(dwHeight)
        m_nWidth= dwHeight 
    end
    
    def SetColWidth(dwWidth) 
	m_nWidth= dwWidth ;
    end
    
    def GetLabel(nType, bBrace)
        return "100"
    end
end

class ZmRCArray
    attr_reader :m_arRC, :m_arLogicRC
    def initialize
        @m_arRC = Array.new         #物理,存ZmRC
        @m_arLogicRC = Array.new    #逻辑,存int
    end
    
    def self=(other)
        @m_arRC = other.m_arRC.dup
        @m_arLogicRC = other.m_arLogicRC.dup
    end
    
    def SetEmpty(nRC)
        nOrder = -1;
        return nOrder if nRC > @m_arRC.length
        if m_arRC[nRC].IsEmpty
            @m_arRC[nRC].SetEmpty(false)
            nOrder = 1;
            (nRC-1).downto(0) do |i|
                if !@m_arRC[i].IsEmpty
                    nOrder = @m_arRC[i].GetOrder() + 1
                    break
                end                
            end
            @m_arRC[nRC].SetOrder(nOrder)
            IncOrder(nRC + 1)
        else
            nOrder = GetOrder(nRC)
            @m_arRC[nRC].SetEmpty(true)
            @m_arRC[nRC].SetOrder(0)
            DecOrder(nRC + 1)
        end
        CreateLogicRC()
        
        return nOrder
    end
    
    def GetSize
        return @m_arRC.length
    end
    
    def IncOrder(nFrom)
        nFrom.upto(@m_arRC.length-1) do |i|
            if (!m_arRC[i].IsEmpty)
                @m_arRC[i].SetOrder(@m_arRC[i].GetOrder() +1)
            end
        end
    end
    
    def DecOrder(nFrom)
        nFrom.upto(@m_arRC.length-1) do |i|
            if (!@m_arRC[i].IsEmpty)
               @m_arRC[i].SetOrder(@m_arRC[i].GetOrder()-1)
            end
        end
    end
    
    def Init(nTotal, nEmpty)
        @m_arRC.clear
        1.upto(nTotal) do |i|
            @m_arRC<<ZmRC.new
        end
        
        Integer(0).upto(nEmpty-1) do |i|
            @m_arRC[i].SetOrder(0)
            @m_arRC[i].SetEmpty(true)
        end
        
        j=1
        nEmpty.upto(nTotal-1) do |i|
            @m_arRC[i].SetOrder(j)
            j += 1
            @m_arRC[i].SetEmpty(false)
        end
        
        CreateLogicRC()
    end
    
    def GetAreaIndex(nRC)
        nSwitch = 0
        bEmpty1 = @m_arRC[nRC].IsEmpty
        bEmpty2 = false
        (nRC-1).downto(0) do |i|
           bEmpty2 = @m_arRC[i].IsEmpty
           
            if ( bEmpty1 && ! bEmpty2 )||(!bEmpty1 && bEmpty2 )
                nSwitch += 1
                bEmpty1 = bEmpty2;
            end
        end
        
        nSwitch/2
    end
    
    #rc类型为CRect
    def GetArea(nCol)
        rc = CRect.new
        rc.left = -1
        rc.right = -1
        nCol.upto(@m_arRC.length) do |i|
           if @m_arRC[i].IsEmpty
               rc.left = i
                (i+1).upto(@m_arRC.length) do |j|
                    if @m_arRC[j].IsEmpty
                        rc.right = j-1
                        break
                    end
                end
                if j==@m_arRC.length
                    rc.right = j-1
                end
           end            
        end
        
        rc
    end
    
    def CreateLogicRC
        @m_arLogicRC.clear
        Integer(0).upto(@m_arRC.length-1) do |i|
           next if @m_arRC[i].IsEmpty
           @m_arLogicRC<<i
        end
    end
    
    def InsertAt(nRC, bEmpty)
        item = ZmRC.new
        item.SetEmpty(bEmpty)
        if !bEmpty
            nOrder = 1
            if @m_arRC.length > 0
                if nRC >= @m_arRC.length
                    nOrder = GetOrder(@m_arRC.length-1)
                    nOrder += 1
                else
                    nOrder = GetOrder(nRC)
                end
                IncOrder(nRC)
            end
            item.SetOrder(nOrder);
        end
        @m_arRC.insert(nRC, item)
        CreateLogicRC()
        item.GetOrder
    end
    
    def DeleteAt(nRC)
        nOrder = @m_arRC[nRC].GetOrder()
        
        if @m_arRC[nRC].IsEmpty
            DecOrder(nRC+1)
        end
        
        m_arRC.delete_at(nRC)
        CreateLogicRC()
        nOrder
    end
    
    def GetOrder(nRC)
        nOrder = 1
        nRC.downto(0) do |i|
            if !@m_arRC[i].IsEmpty
                nOrder = @m_arRC[i].GetOrder
                break
            end
        end
        nOrder
    end
    
    def GetLogicCount
        @m_arLogicRC.length
    end
    
    def GetHideNum
        nHide = 0
        Integer(0).upto(@m_arRC.length-1) do |i|
           nHide += 1 if @m_arRC[i].IsHide 
        end
        nHide
    end
end
