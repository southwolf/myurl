require 'fpdf'
require 'chinese'
require "xmlhelper"
require "test/unit"


class PDF < FPDF
	def write_tables(tables, dictFactory = nil)
		for table in tables
			AddPage()
			Integer(0).upto(table.GetRowCount()-1) do |row|
				Integer(0).upto(table.GetColumnCount()-1) do |col|
					cell = table.GetCell(row, col)
					
					if table.IsEmptyRow(row) || table.IsEmptyCol(col) || !cell.IsStore()
				      SetFillColor(200, 200, 200)
				      
				    else
				      SetFillColor(255, 255, 255)
				    end
					
					
					if !cell.IsEffective()
						#判断是被上边单元格覆盖还是被左边单元格覆盖
						upCovered = false
						Integer(row-1).downto(0) do |erow|
							upcell = table.GetCell(erow, col)
							if upcell.IsEffective 
								if upcell.GetCoveredScale.cy > 1	
									upCovered = true
								end
								break
							end
						end
						next if !upCovered
						
						Cell(table.GetColWidth(col)/16, table.GetRowHeight(row)/16, cell.GetText(), 'LR', 0, 'L')
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
        	        
					Cell(width, height, cell.GetText(), 'LTRB', 0, 'L', 1)
				end
				Ln()
			end
		end
	end
end

class TestPDF < Test::Unit::TestCase
	def test1
		pdf = PDF.new
		pdf.Open
		pdf.extend(PDF_Chinese)
		pdf.AddGBFont('simsun', EncodeUtil.change('GB2312', 'UTF-8', '宋体')); 
		pdf.AddGBFont('simhei', EncodeUtil.change('GB2312', 'UTF-8', '黑体')); 
		pdf.AddGBFont('simkai', EncodeUtil.change('GB2312', 'UTF-8', '楷体')); 
		pdf.AddGBFont('sinfang',EncodeUtil.change('GB2312', 'UTF-8', '仿宋')); 
		pdf.SetFont('simsun', '', 9);
		
		helper = XMLHelper.new
		helper.MS_ReadFromXMLFile('d:\param\kb.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        
        pdf.SetFont('simsun','',9); 
        #pdf.AddPage()
        #pdf.Write(10, EncodeUtil.change('GB2312', 'UTF-8', '你好'));
        #pdf.Write(10, 'aa'); 
        pdf.write_tables(tables, dictFactory)
	pdf.Output('example.pdf')	
	end
end