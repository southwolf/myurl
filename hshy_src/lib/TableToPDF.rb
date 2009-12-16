require 'fpdf'
require 'chinese'
require "XMLHelper"

class PDF < FPDF
  def write_tables(tables, dictFactory = nil)
    for table in tables
      AddPage()
      Integer(0).upto(table.GetRowCount()-1) do |row|
        p row
        x = GetX()
        y = GetY()
        Integer(0).upto(table.GetColumnCount()-1) do |col|
          cell = table.GetCell(row, col)
          if table.IsEmptyRow(row) || table.IsEmptyCol(col) || !cell.IsStore()
            SetFillColor(200, 200, 200)
          else
            SetFillColor(255, 255, 255)
          end
				    
          text = cell.GetText()
          p text
          if cell.GetInputType() == CCell::ItComboBox && dictFactory
            dictID = cell.GetDictName()
            dict = dictFactory.GetDictionByID(dictID.to_s)
            if dict                           
              text = EncodeUtil.change("GB2312", "UTF-8", dict.GetItemName(text.to_s))
            end
          end					
					
          if !cell.IsEffective()
            #判断是被上边单元格覆盖还是被左边单元格覆盖
            upCovered = false
            Integer(row-1).downto(0) do |erow|
              upcell = table.GetCell(erow, col)
              if upcell.IsEffective && upcell.GetCoveredScale.cy > row-erow				    
                upCovered = true
              end
            end
						
            leftCovered = false
            Integer(col-1).downto(0) do |ecol|
              leftcell = table.GetCell(row, ecol)
              if leftcell.IsEffective && leftcell.GetCoveredScale.cx > col-ecol
                leftCovered = true
              end
            end
						
            next if !upCovered && leftCovered
						
            Cell(table.GetColWidth(col)/16, table.GetRowHeight(row)/16, text, 'LR', 0, 'L')
            next
          end
					
          #获得行高列宽
          height = 0
          Integer(row).upto(row+cell.GetCoveredScale().cy-1) do |srow|
            height += table.GetRowHeight(srow)/16
          end
        	        
          width = 0
          Integer(col).upto(col+cell.GetCoveredScale().cx-1) do |scol|
            width += table.GetColWidth(scol)/16
          end 
        	        
          if cell.GetHoriAlign() == 0
            align = 'L'
          elsif cell.GetHoriAlign() == 1
            align = 'C'
          else
            align = 'R'
          end
        	        
          Cell(width, height, text, 'LTRB', 0, align, 1)
        end
        Ln()
        #SetX(x+table.GetRowHeight(row)/16)
        SetY(y+table.GetRowHeight(row)/16)
      end
    end
  end
end
