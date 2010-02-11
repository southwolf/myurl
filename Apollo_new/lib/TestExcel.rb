require "spreadsheet/excel"
require "xmlhelper"
require "test/unit"
require "EncodeUtil"
include Spreadsheet

class TestTableLib < Test::Unit::TestCase
	def test_1
		helper = XMLHelper.new
		helper.MS_ReadFromXMLFile('d:\param\kb.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        
        workbook = Excel.new("table.xls")
        for table in tables
            f_row = workbook.add_format(:color=>"black", :bold=>0, :italic=>false, :text_wrap=>true)
            
            #跨行失效单元格
            f_not_effect_rows = workbook.add_format(:color=>"black", :align=>"merge", :bg_color=>"grey", :text_wrap=>true)
            f_not_effect_rows.left = f_not_effect_rows.right = 1
            
            #跨列失效单元格
            f_not_effect_cols = workbook.add_format(:color=>"black", :align=>"merge", :bg_color=>"grey", :text_wrap=>true)
            f_not_effect_cols.top = f_not_effect_cols.bottom = 1
            
            #跨行列失效单元格
            f_not_effect_rows_cols = workbook.add_format(:color=>"black", :align=>"merge", :bg_color=>"grey", :text_wrap=>true)
            
            #普通单元格
            f_normal = workbook.add_format(:color=>"black", :bold=>0, :italic=>false, :text_wrap=>true)
            f_normal.top = f_normal.bottom = f_normal.left = f_normal.right = 1
            
            #跨行合并单元格
            f_normal_rows = workbook.add_format(:color=>"black", :bg_color=>"grey",:text_wrap=>true)
            f_normal_rows.top = f_normal_rows.left = f_normal_rows.right = 1
            f_normal_rows.bottom = 0
            f_normal_rows.align= "merge"
            
            #跨列合并单元格
            f_normal_cols = workbook.add_format(:color=>"black", :bg_color=>"grey", :text_wrap=>true)
            f_normal_cols.top = f_normal_cols.bottom = f_normal_cols.left = 1
            f_normal_cols.right = 0
            f_normal_cols.align= "merge"
            
            #跨行又跨列的单元格
            f_normal_rows_cols = workbook.add_format(:color=>"black", :bg_color=>"grey", :text_wrap=>true)
            f_normal_rows_cols.top = f_normal_cols.left = 1
            f_normal_rows_cols.right = 0            
            f_normal_rows_cols.bottom = 0
            f_normal_rows_cols.align= "merge"
            
            f_empty = workbook.add_format(:color=>"black", :bold=>0, :bg_color=>"grey")
            f_empty.left = f_empty.right = f_empty.top = f_empty.bottom = 1
        	worksheet = workbook.add_worksheet(EncodeUtil.change("GB2312", "UTF-8", table.GetTableName()))
        	
        	Integer(0).upto(table.GetRowCount()-1) do |row|
        	   worksheet.format_row(row, table.GetRowHeight(row)/4.7, f_row)
        	end
        	
        	Integer(0).upto(table.GetColumnCount()-1) do |col|
        	   worksheet.format_column(col, table.GetColWidth(col)/27.5, f_row)
        	end
        	
        	#写入单元格数据
        	Integer(0).upto(table.GetRowCount()-1) do |row|
        	   Integer(0).upto(table.GetColumnCount()-1) do |col|
        	     cell = table.GetCell(row, col)
        	     next if !cell.IsEffective()
        	     format = workbook.add_format(:color=>"black", :align => "merge")
        	     format.top = format.bottom = format.left = format.right = 1
        	     if table.IsEmptyRow(row) || table.IsEmptyCol(col) || !cell.IsStore()
        	       format.bg_color = "grey"
        	     end
        	     format.bottom = 0 if cell.GetCoveredScale().cy > 1
        	     format.right = 0 if cell.GetCoveredScale().cx > 1
        	     format.right = format.bottom = 0 if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx > 1
        	     f = format
        	     
        	     
        	     worksheet.write(row, col, cell.GetText(), format)
        	     
        	     #跨行列
        	     if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx > 1
        	       Integer(row).upto(row+cell.GetCoveredScale().cy-1) do |srow|
        	         Integer(col).upto(col+cell.GetCoveredScale().cx-1) do |scol|
        	           format.bottom = format.top = format.left = format.right = 0
        	           next if row == srow && col == scol
        	           worksheet.write(srow, scol, nil, format)
        	         end
        	       end
        	       next
        	     end
        	     
        	     #跨行
        	     if cell.GetCoveredScale().cy > 1
        	         Integer(row+1).upto(row+cell.GetCoveredScale().cy-1) do |srow|
        	           format.left = format.right = 1
        	           format.top = format.bottom = 0
        	           worksheet.write(srow, col, nil, format)
        	         end
        	     end
        	     
        	     #跨列
        	     if cell.GetCoveredScale().cx > 1
        	         Integer(col+1).upto(col+cell.GetCoveredScale().cx-1) do |scol|
        	           newformat = workbook.add_format(:color=>"black", :align => "merge")
        	           newformat.top = newformat.bottom = 1
        	           newformat.left = newformat.right = 0
        	           newformat.bg_color = format.bg_color
        	           if scol == table.GetColumnCount()-1
        	             newformat.right = 1
        	           end
        	           worksheet.write(row, scol, nil, newformat)
        	         end
        	     end
        	     
        	   end
        	end
        end
        
        workbook.close
	end
end