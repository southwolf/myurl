require "Cell"
require "Style"
require "StyleManager"
require "Diction"
require "Size"
require "ZmRC"
require "Cell"

class CTable
    DELTA_SCALE = 5
    DF_RULE_HEIGHT = (17 * DELTA_SCALE)
    DF_RULE_WIDTH  = (24 * DELTA_SCALE)
    TC_TF_SUM	= 0x00000008
    TC_TF_AUTO_CACL = 0x00000800
    TC_TF_SUM_ADDUP = 0x00000010
    TC_TF_FACETABLE = 0x00000001
    TC_TF_MUSTFILLTABLE = 0x00000002
    DF_CELL_WIDTH = (54  * DELTA_SCALE)
    
    attr_reader :m_lColWidth, :m_lRowHeight
    attr_reader :m_zmRow, :m_zmCol
    def initialize(styleManager, id, name)
        @m_TableID = id
        @m_TableName = name
        @m_zmRow = ZmRCArray.new
        @m_zmCol = ZmRCArray.new
        @m_pStyleManager = styleManager
        @_dicFactory = DictionFactory.new
        @m_rcFreeze = CRect.new(-1, -1, -1, -1)
        @m_nRow = 4
        @m_nCol = 4
        @m_lColWidth = Array.new
        @m_lRowHeight = Array.new
        @m_pDataBoxes = Array.new
        @m_properties = Hash.new
    end
    
    #��ñ�����
    def GetTableName
        @m_TableName
    end
    
    #��ñ�ID
    def GetTableID
        @m_TableID
    end
    
    #��÷�����������
    def GetStyleManager
        @m_pStyleManager
    end
    
    #�����±�
    #nRow : ����
    #nCol : ����
    #nHeadRow : �̶���ͷ����
    #nHeadCol : �̶���ͷ����
    def OnNewTable(nRow, nCol, nHeadRow, nHeadCol)
        @m_nRow = nRow + nHeadRow
        @m_nCol = nCol + nHeadCol
        @m_rcFree = CRect.new(-1, -1, -1, -1)
        
        @m_lColWidth.clear
        1.upto(@m_nCol) do |i|
            @m_lColWidth << DF_CELL_WIDTH
        end
        
        @m_lRowHeight.clear
        1.upto(@m_nRow) do |i|
            @m_lRowHeight << DF_RULE_HEIGHT 
        end
        
        @m_zmRow.Init(@m_nRow, nHeadRow)
        @m_zmCol.Init(@m_nCol, nHeadCol)
        
        @m_pDataBoxes.clear
        1.upto(@m_nRow*@m_nCol) do |i|
            @m_pDataBoxes << CCell.new 
        end
        
        nHeadRow.upto(@m_nRow-1) do |row|
            nHeadCol.upto(@m_nCol-1) do |col|
                cell = GetCell(row, col)
                cell.SetAttribute(CCell::TC_CF_STORE, true)
            end
        end
        
        style = @m_pStyleManager.NewStyle()
        Integer(0).upto(@m_nRow-1) do |row|
            Integer(0).upto(@m_nCol-1) do |col|
               GetCell(row, col).SetStyle(style) 
            end
        end
    end
    
    #��õ�Ԫ�����
    #nRow : �����к�
    #nCol : �����к�
    def GetCell(nRow, nCol)
        @m_pDataBoxes[nRow*GetColumnCount()+nCol]
    end
    
    def GetMaxDataRow
        @m_zmRow.GetLogicCount
    end
        
    def GetMaxDataCol
        @m_zmCol.GetLogicCount
    end
    
    #���������
    def GetRowCount
        @m_nRow
    end
    
    #���������
    def GetColumnCount
        @m_nCol
    end
    
    #����������򣬳��̶��й̶����⣬�������е�Ԫ���ֵȫ���
    def ClearDataArea
        Integer(0).upto(GetRowCount()-1) do |row|
            Integer(0).upto(GetColumnCount()-1) do |col|
                GetCell(row, col).SetText("")
            end
        end
    end
    
    
    def GetMappingBox(ptCell)
        pt = CPoint.new(ptCell.x, ptCell.y)
        if ptCell.x ==2 && ptCell.y == 0
            ptCell = ptCell
        end
        if(ptCell.x < GetColumnCount() && ptCell.x >=0	&& ptCell.y < GetRowCount() && ptCell.y >=0)
            pCell = GetCell(ptCell.y, ptCell.x)
            if !pCell.IsEffective
                sz = pCell.GetMappingBox
                pt = CPoint.new(ptCell.x-sz.cx, ptCell.y - sz.cy)
            end
        end
        pt.x = 0 if pt.x<0
        pt.y = 0 if pt.y<0
        
        pt.x = GetColumnCount()-1 if pt.x >= GetColumnCount()
        pt.y = GetRowCount()-1 if pt.y >= GetRowCount()
        
        pt
    end
    
    #���õ�Ԫ��ֵ
    #nRow : ��Ԫ������������
    #nCol : ��Ԫ������������
    #vt : ��Ԫ���ֵ���������κ����ͣ����ȡֵ��ʱ�򶼻�ת��Ϊ�ַ���
    def SetCellValue(nRow, nCol, vt)
        cell = GetCell(nRow, nCol)
        if cell.IsNumeric
            cell.SetText vt
        elsif cell.IsText
            cell.SetText vt
        elsif cell.IsVarText
            cell.SetText vt
        elsif cell.IsDate
            cell.SetText vt
        end
    end
    
    #��õ�Ԫ��ֵ�������ַ���
    #nRow : ��Ԫ������������
    #nCol : ��Ԫ������������
    def GetCellValue(nRow, nCol)
        ptCell = CPoint.new(nCol, nRow)
        ptCell = GetMappingBox(ptCell)
        pCell = GetCell(ptCell.y, ptCell.x)
        return pCell.GetText.to_s
    end
    
    #����һ�ű��Ʊ����ݣ�����������������ÿ����Ԫ������ԣ�����
    #other : ���Ƶ�Դ��
    def Copy(other)
        @m_pStyleManager = other.GetStyleManager()
        @m_TableID = other.GetTableID
        @m_TableName = other.GetTableName
        @m_nRow = other.GetRowCount
        @m_nCol = other.GetColumnCount
        @m_lColWidth = other.m_lColWidth
        @m_lRowHeight = other.m_lRowHeight
        
        @m_zmRow.m_arRC.clear
        for element in other.m_zmRow.m_arRC
            @m_zmRow.m_arRC<<element
        end
        @m_zmRow.m_arLogicRC.clear
        for element in other.m_zmRow.m_arLogicRC
            @m_zmRow.m_arLogicRC<<element
        end
        @m_zmCol.m_arRC.clear
        for element in other.m_zmCol.m_arRC
            @m_zmCol.m_arRC<<element
        end
        @m_zmCol.m_arLogicRC.clear
        for element in other.m_zmCol.m_arLogicRC
            @m_zmCol.m_arLogicRC<<element
        end
        
        #print "copy table row #{m_nRow}, col #{m_nCol}"
        @m_nRow = other.GetRowCount()
        @m_nCol = other.GetColumnCount()
        @m_pDataBoxes.clear
        1.upto(@m_nRow*@m_nCol) do |i|
            @m_pDataBoxes << CCell.new 
        end
        
        Integer(0).upto(other.GetRowCount()-1) do |row|
            Integer(0).upto(other.GetColumnCount()-1) do |col|
                cell = GetCell(row, col)
                cell.copy(other.GetCell(row, col))               
            end
        end
    end
    
    #���õ�Ԫ������
    #�����������ã�SetCellProperty(prop, row, col) => ֻ���õ�����Ԫ������
    #ҳ�����������ã�SetCellProperty(prop, top, left, bottom, right) => ����һ������Ԫ������
    #prop : Hash���󣬴�� ��������=>ֵ ��
    def SetCellProperty(prop, *args)
        if args.length == 2     #SetCellProperty(prop, row, col)
            _SetCellProperty(prop, args[0], args[1])
        elsif args.length == 4  #SetCellProperty(prop, top, left, bottom, right
            top = args[0]
            left = args[1]
            bottom = args[2]
            right = args[3]
            top.upto(bottom) do |row|
                left.upto(right) do |col|
                   _SetCellProperty(prop, row, col) 
                end
            end
        elsif args.length == 1  #SetCellProperty(prop, rect)
            rect = args[0]
            rect.top.upto(rect.bottom) do |row|
                rect.left.upto(rect.right) do |col|
                    _SetCellProperty(prop, row, col)   
                end
            end
        end
    end
    
    #��õ�Ԫ������
    #row : ��Ԫ��������
    #col : ��Ԫ��������
    #key : ��������
    def GetCellProperty(row, col, key)
        return "" if row>=@m_nRow || col >=@m_nCol
        @m_pStyleManager.GetStyleAttribute(GetCell(row, col), key)
    end
    
    #�ж����Ƿ��ǿ��У��̶��У�����0��ʼ����
    def IsEmptyCol(nCol)
        return false if(nCol >= @m_zmCol.m_arRC.length)
	return @m_zmCol.m_arRC[nCol].IsEmpty()
    end
    
    #�ж����Ƿ��ǿ��У��̶��У�����0��ʼ����
    def IsEmptyRow(nRow)
        @m_zmRow.m_arRC[nRow].IsEmpty()
    end
    
    #������Ϊ���У��̶��У�����0��ʼ����
    def SetEmptyCol(nCol)
        return if(nCol >= @m_zmCol.m_arRC.length) 
        bEmpty = IsEmptyCol(nCol)
        bSetToEmpty = !bEmpty
        if(bSetToEmpty)
	    Integer(0).upto(GetRowCount()-1) do |i|
                t_Cell = GetCell(i, nCol);
                t_Cell.SetAttribute(CCell::TC_CF_STORE, false);
            end
	else
            Integer(0).upto(GetRowCount()-1) do |i|
                if(!IsEmptyRow(i))
                    t_Cell = GetCell(i, nCol);
		    t_Cell.SetAttribute(CCell::TC_CF_STORE, true);
                end
            end
        end
        @m_zmCol.SetEmpty(nCol) ;
    end
    
    #������Ϊ���У��̶��У�����0��ʼ����
    def SetEmptyRow(nRow)
        return if(nRow >= @m_zmRow.m_arRC.length)
        bEmpty =  IsEmptyRow(nRow)
        bSetToEmpty = !bEmpty;
	if(bSetToEmpty)
            Integer(0).upto(GetColumnCount()-1) do |i|
		t_Cell = GetCell(nRow,i);
		t_Cell.SetAttribute(CCell::TC_CF_STORE,FALSE);
	    end
	elsif
	    Integer(0).upto(GetColumnCount()) do |i|
		if(!IsEmptyCol(i))
                    t_Cell = GetCell(nRow,i);
                    t_Cell.SetAttribute(CCell::TC_CF_STORE,TRUE);
		end
	    end
	end

	@m_zmRow.SetEmpty(nRow) 
    end
 
    #����ĳ��Ϊ������
    #nRow : �����к�
    #value : true or false
    def SetFloatTemplateRow(nRow, value)
	@m_zmRow.m_arRC[nRow].SetAttribute(ZmRC::TC_RCF_FLOATTEMPL, value);
    end
    
    #�ж�ĳ���Ƿ��Ǹ����У�������true or false����0��ʼ����
    def IsFloatTemplRow(nRow)
        if nRow >=  m_zmRow.m_arRC.size
		return false
        end
        
        @m_zmRow.m_arRC[nRow].IsFloatTempl()
    end
    
    #�ж�һ�ű��ǲ��Ǹ���������true or false
    def IsFloatTable
      result = false
      
      Integer(0).upto(GetRowCount()-1) do |row|
        return true if IsFloatTemplRow(row)
      end
      
      result
    end
    
    #����ĳ��Ϊ����
    #nRow : �к�
    #bHidden : true or false
    def SetRowHidden(nRow, bHidden)
        @m_zmRow.m_arRC[nRow].SetHide(bHidden);
    end
    
    #�ж�ĳ���Ƿ�����
    #nRow : �к�
    def IsRowHidden(nRow)
        @m_zmRow.m_arRC[nRow].IsHide()
    end
    
    #����ĳ��Ϊ����
    #nRow : �к�
    #bHidden : true or false
    def SetColHidden(nCol, bHidden)
        @m_zmCol.m_arRC[nCol].SetHide(bHidden);
    end
    
    #�ж�ĳ���Ƿ�����
    #nRow : �к�
    def IsColHidden(nCol)
        return if(nCol >= @m_zmCol.m_arRC.length)
				return  @m_zmCol.m_arRC[nCol].IsHide()
    end
    
    #����и߶�
    #nRow : �к�
    def GetRowHeight(nRow)
        @m_lRowHeight[nRow]
    end
    
    #�����и߶�
    #nRow : �к�
    #nHeight : �и�
    def SetRowHeight(nRow, nHeight)
        @m_lRowHeight[nRow]= nHeight;
    end
    
    #����п��
    #nCol : �к�
    def GetColWidth(nCol)
        @m_lColWidth[nCol]
    end
    
    #�����и߶�
    #nRow : �к�
    #nHeight : �и�
    def SetColWidth(nCol, nHeight)
        @m_lColWidth[nCol]= nHeight;
    end
    
    #�ϲ���Ԫ��
    #�����������ã�Merge(rect)
    #Ҳ�����������ã�Merge(top, left, bottom, right)
    def Merge(*args)
        if args.length == 1
            rect = args[0]
            row1 = rect.top
            col1 = rect.left
            row2 = rect.bottom
            col2 = rect.right
        elsif args.length == 4
            row1 = args[0]
            col1 = args[1]
            row2 = args[2]
            col2 = args[3]
        end
        row1.upto(row2) do |row|
            col1.upto(col2) do |col|
               cell = GetCell(row, col)
               cell.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
               cell.SetMappingBox(CSize.new(col - col1, row - row1))
            end
        end
        cell = GetCell(row1, col1)
        cell.SetAttribute(CCell::TC_CF_EFFECTIVE, true)
        cell.SetMappingBox(CSize.new(col2 - col1+1, row2 - row1+1))
    end
    
    #������
    #lCurRow : ��ǰ��
    def InsertRow(lCurRow)
        lInsRow = lCurRow
        if lCurRow >= GetRowCount()
            bHead = IsEmptyRow(GetRowCount()-1)
        elsif
            bHead = IsEmptyRow(lCurRow)
        end
        
        #����ϲ���Ԫ������..

        style = @m_pStyleManager.NewStyle()
        Integer(1).upto(GetColumnCount()) do |i|
            cell = CCell.new
            cell.SetStyle(style)
            @m_pDataBoxes.insert(lInsRow*GetColumnCount(), cell)    
        end
        
        @m_lRowHeight.insert(lInsRow, DF_RULE_HEIGHT)
        @m_nRow += 1
        
        @m_zmRow.InsertAt(lInsRow, bHead)
    end
    
    #������
    #lCurRow : ��ǰ��
    def InsertCol(lCurCol)
        lInsCol = lCurCol
        if lCurCol >= GetColumnCount()
            bHead = IsEmptyCol(GetColumnCount() -1 )
        else
            bHead = IsEmptyCol(lCurCol)
        end
        
        #����ϲ����..

        style = @m_pStyleManager.NewStyle()
        deta=0
        Integer(0).upto(GetRowCount()-1) do |i|
            cell = CCell.new()
            cell.SetStyle(style)
            index = i*GetColumnCount() + lInsCol + deta
            @m_pDataBoxes.insert(index, cell)
            deta += 1
        end
        @m_lColWidth.insert(lInsCol, DF_CELL_WIDTH)
        @m_nCol+=1
        
        @m_zmCol.InsertAt(lInsCol, bHead)
    end
    
    #�ӵ�Ԫ�����ƻ�õ�Ԫ�����
    #fieldName : ����
    def GetCellByFieldName(fieldName)
        fieldName = fieldName.upcase
        Integer(0).upto(GetRowCount()-1) do |row|
            Integer(0).upto(GetColumnCount()-1) do |col|
               #print "row#{row}, col#{col}\n"
               cell = GetCell(row, col)
               
               next if !cell.IsEffective()
               return [row, col] if fieldName.downcase == GetCellDBFieldName(row, col).downcase
            end
        end
        return [-1, -1]
    end
    
    #��õ�Ԫ������ݿ����ƣ������ַ�������������ȡ���ƣ���������ȡ�кż��кţ���A8��B2��
    #nRow : �к�
    #nCol : �к�
    def GetCellDBFieldName(nRow, nCol)
        cell = GetCell(nRow, nCol)
        return "" if !cell
        
        return "" if !cell.IsEffective() || !cell.IsStore()
        
        csFieldName = cell.GetName()
        if csFieldName.empty?
            csFieldName = GetCellLabel(nRow, nCol)
        end
        
        #csFieldName = csFieldName.upcase()
        csFieldName.downcase
    end
    
    #��õ�Ԫ���ǩ����A8��B2
    #nRow : �к�
    #nCol : �к�
    def GetCellLabel(nRow, nCol)
        nPhRow = nRow
        nPhCol = nCol
        nRow = PhyRowToLogicRow(nRow+1)
        nCol = PhyColToLogicCol(nCol+1)
        
        if (nCol<1 || nRow<1)
            cell = GetCell(nPhRow, nPhCol)
            return cell.GetName() if cell.IsEffective() && cell.IsStore()
        end
        
        devi = nCol / 26
        remain = nCol % 26
        if remain == 0
      	 devi -= 1
	     remain = 26
        end

        if devi > 0
         "#{(devi+64).chr}#{(remain+64).chr}#{nRow}"
        else
	     "#{(remain+64).chr}#{nRow}"
        end
        
        #"#{(nCol+64).chr}#{nRow}"
    end
    
    #������תΪ�߼��У�nPhyRow��1��ʼ
    def PhyRowToLogicRow(nPhyRow)
	return @m_zmRow.m_arRC[nPhyRow - 1].GetOrder()
    end
    
    #������תΪ�߼��У�nPhyCol��1��ʼ
    def PhyColToLogicCol(nPhyCol)
	return @m_zmCol.m_arRC[nPhyCol - 1].GetOrder()
    end
    
    #�߼���תΪ�����У�nLogicCol��1��ʼ
    def LogicColToPhyCol(nLogicCol)
        count = 0
        Integer(0).upto(GetColumnCount()-1) do |col|
            count += 1 if !IsEmptyCol(col)
            if count == nLogicCol
                count = col
                break
            end
        end
        
        count
    end
    
    #�߼���תΪ�����У�nLogicRow��1��ʼ
    def LogicRowToPhyRow(nLogicRow)
        count = 0
        Integer(0).upto(GetRowCount()-1) do |row|
            count += 1 if !IsEmptyRow(row)
            if count == nLogicRow
                count = row
                break
            end
        end
        
        count
    end
    
    def GetDataAreaRect
        rect = CRect.new(0, 0, GetColumnCount()-1, GetRowCount()-1)
        Integer(0).upto(GetRowCount()-1) do |row|
            if IsEmptyRow(row)
                rect.top += 1
            else
                break
            end
        end
        
        Integer(0).upto(GetColumnCount() -1) do |col|
            if IsEmptyCol(col)
                rect.left += 1
            else
                break
            end
        end
        
        return rect
    end
    
    #��ñ��ܿ��
    def GetTotalWidth()
        result = 0
        index = 0
        for width in @m_lColWidth
        		if IsColHidden(index)
        			index += 1
        			next
        		end
        		
            result += width
            
            index += 1
        end
        result
    end
    
    #��ñ�߶�
    def GetTotalHeight()
        result = 0
        for height in @m_lRowHeight
            result += height
        end
        result
    end
    
    #��ñ�����
    #key : ��������
    def GetProperty(key)
      @m_properties[key]
    end
    
    #���ñ�����
    #key : ��������
    #value : ����ֵ
    def SetProperty(key, value)
      @m_properties[key] = value
    end
    
    #�����������
    def GetAllProperties()
      @m_properties
    end
    
    #���������������ֻҪ��Ԫ���������
    def ClearDataArea
        Integer(0).upto(GetRowCount()-1) do |row|
            Integer(0).upto(GetColumnCount()-1) do |col|
                cell = GetCell(row, col)
                if cell.IsEffective() && cell.IsStore()
                    cell.SetText("")
                end
            end
        end
    end
    
    #��ʽ��غ�����ģ���ѯ��ʽ�����ʵ�Ԫ��ʹ��cells[1, 2],��ȻҲ����ʹ��a1,b1�������������ڱ��ѭ������
    def cells
        self
    end
    
    #��ʽ��غ�����ģ���ѯ��ʽ������Ԫ��ֵʹ��cells[1, 2]=
    def []=(*args)
        return  if args.size != 3
        
        cell = GetCell(args[0], args[1])
        cell.SetText(args[2].to_s) if cell
        
        cell.GetTypedValue
    end
    
    #��ʽ��غ�����ģ���ѯ��ʽ��ȡ��Ԫ��ֵʹ��cells[1, 2]
    def [](*args)
        return  if args.size != 2
        if cell = GetCell(args[0], args[1])
            return cell.GetTypedValue()
        else
            return ""
        end
    end
    
    #����ģ�͵�����XML��
    #node : REXML�Ľڵ����
    def OutputXML(node)
        tableattr = Hash.new
        tableattr['ColCount'] = GetColumnCount().to_s
        tableattr['DefaultColWidth']= "270"
        tableattr['DefaultRowHeight'] = "85"
        tableattr['Protected'] = "0"
        tableattr['RowCount'] = GetRowCount().to_s
        tableattr['TableID'] = GetTableID()
        tableattr['TableName'] = GetTableName()
        tableattr['ZoomScale'] = "1.00"
        node.add_attributes(tableattr)
        
        print GetTableID() + "\n"
        
        Integer(0).upto(@m_zmCol.m_arRC.length-1) do |i|
            colnode = node.add_element(Element.new('Col'))
            colattr = Hash.new
            if @m_zmCol.m_arRC[i].IsEmpty
                colattr['Empty'] = "1"
            else
                colattr['Empty'] = "0"
            end
            if @m_zmCol.m_arRC[i].IsHide
                colattr['Hidden'] = "1"
            else
                colattr['Hidden'] = "0"
            end
            colattr['Flag1'] = "false"
            colattr['Flag2'] = "false"
            colattr['Flag3'] = "false"
            colattr['Flag4'] = "false"
            colattr['Index'] = i.to_s
            colattr['Width'] = @m_lColWidth[i]
            colnode.add_attributes(colattr)
            
            #print "col " + i.to_s + "\n"
        end
        
        Integer(0).upto(@m_zmRow.m_arRC.length-1) do |row|
            rownode = node.add_element(Element.new('Row'))
            rowattr = Hash.new
            if @m_zmRow.m_arRC[row].IsEmpty
                rowattr['Empty'] = "1"
            else
                rowattr['Empty'] = "0"
            end
            if @m_zmRow.m_arRC[row].IsHide
                rowattr['Hidden'] = "1"
            else
                rowattr['Hidden'] = "0"
            end
            rowattr['Flag1'] = "false"
            rowattr['Flag2'] = "false"
            rowattr['Flag3'] = "false"
            rowattr['Flag4'] = "false"
            rowattr['Index'] = row.to_s
            rowattr['Height'] = @m_lRowHeight[row]
            rownode.add_attributes(rowattr)
            
            if IsFloatTemplRow(row)
                parameters = rownode.add_element(Element.new('Parameters'))
                param = parameters.add_element('Parameter')
                param.add_element('Key').text = 'IsFloatTemplateRow'
                param.add_element('Value').text = 'True'
            end
            
            #print "row " + row.to_s + "\n"
            
            Integer(0).upto(GetColumnCount()-1) do |col|
               cell = GetCell(row, col)
               #print "styleID : cell.GetStyle().GetID() "
              
               if cell.IsEffective && cell.GetStyle().GetID()>-1
                   cellnode = rownode.add_element(Element.new('Cell'))
                   cell.OutputXML(cellnode, col) if cell.IsEffective()
               end               
            end
        end
        
        node_params = node.add_element(Element.new('Parameters'))
            
            GetAllProperties().each{|key, value|
              node_param = node_params.add_element(Element.new('Parameter'))
              node_param.add_element('Key').text = key
              node_param.add_element('Value').text = value
        }
    end
    
    #��ʼ����ʽ����
    def InitScriptEngine(book)
        @book = book
        
        #�ӱ���󣬱�����T1��ռ���ִ��A1=T2.B1 + C1,����T2����
        for table in book.tables
            next if table.GetTableID() == GetTableID()
            instance_eval("def #{table.GetTableID().downcase()}
                            for table in @book.tables
                                return table if table.GetTableID().downcase() == #{table.GetTableID().downcase()}
                            end
                            nil
                          end")
        end
        
        #���ж��󣬱���A = B + C

        #���ж��󣬱���[1] = [2] + [3]

        #�ӵ�Ԫ�����, ����A1 = B1 + C1
    end
    
private
    def _SetCellProperty(prop, row, col)
        cell = GetCell(row, col)
        newStyle = GetStyleManager().NewStyle(cell.GetStyle(), prop)
        cell.SetStyle(newStyle)
        _SetCell(cell, prop)
    end
    
    def _SetCell(pCell, prop)
        prop.each{|type, value|
            if(type == StyleManager::PROP_fieldName)
                pCell.SetName(value)			
            elsif(type == StyleManager::PROP_description)
                pCell.SetDescription(value);
            elsif(type == StyleManager::PROP_isStore)
                pCell.SetAttribute(CCell::TC_CF_STORE, value=="true");
            elsif(type == StyleManager::PROP_isConvert)
                pCell.SetAttribute(CCell::TC_CF_PRECISION, value == "true");
            elsif(type == StyleManager::PROP_isSum)
                if (pCell.IsNumeric())
                    pCell.SetAttribute(CCell::TC_CF_SUM, value == "true");
                end
            elsif(type == StyleManager::PROP_dictionary) 
                pCell.SetDictName(value);
            elsif(type == StyleManager::PROP_dictItem) 
                pCell.SetDisplayType(value.to_i);
            end
        }
    end
    
    
    
    
    def method_missing(method_id, *args)
        name = method_id.id2name
        if name.downcase == "rowcount"
            return GetRowCount()
        elsif name.downcase == "colcount"
            return GetColumnCount()
        end

        rowcol = GetCellByFieldName(name)
        if rowcol[0] == -1
            #print "#{cellname} not found\n"
        else
            #print "#{name} found, value #{GetCell(rowcol[0], rowcol[1]).GetText()}\n"
        end
        
        GetCell(rowcol[0], rowcol[1]).GetTypedValue()
    end
end
