require "Table"
require "StyleManager"
require "Diction"
require "iconv"
require "Size"
require "Style"
require "EncodeUtil"
require "Cell"
require "spreadsheet/excel"

include Spreadsheet

class TableToExcel
   
    #将表导出到Excel
    #outTables : 数组，默认为nil，数组元素是CTable表,如果为空则取本对象的表数组
    #dictFactory : 代码字典工厂，可以将代码型单元格的字符串转变为含义
    def ExportToExcel(outTables = nil, dictFactory = nil, session = nil)
		#进行判断操作系统的类型，如果是windows,并安装excel则执行以下导出
		
		#windows接口控件速度实在太慢，废除
		if $OS == "WINDOWS" && nil
		    require "spreadsheet/win_excel" 
	   		excel = WIN_Excel::WorkBook.new
	   		return ExportToExcel_Com(outTables, dictFactory, session, excel) if excel
		end
		return ExportToExcel_Linux(outTables, dictFactory, session)
	end
	
	def ExportToExcel_Linux(outTables, dictFactory, session)
		workbook = Excel.new("tmp/table.xls")
		outTables = tables if outTables == nil
		for table in outTables
		    worksheet = workbook.add_worksheet(EncodeUtil.change("GB2312", "UTF-8", table.GetTableName()))
            
            f_row = workbook.add_format(:color=>"black", :bold=>0, :italic=>false, :text_wrap=>true)
            nRowCount = 0
			Integer(0).upto(table.GetRowCount()-1) do |row|
                worksheet.format_row(nRowCount, table.GetRowHeight(row)/5.7, f_row)

                logicRow = table.PhyRowToLogicRow(row+1)
               
                nRowCount += 1
                #如果是浮动表，并且此行是浮动行，则需要读取浮动行明细记录
                records = nil
                if table.IsFloatTable() && table.IsFloatTemplRow(row) && session
                  require "Util"
                  records = Util.GetFloatData(session[:task].strid, table.GetTableID(), logicRow, session[:unitid], session[:tasktime], 1, 50000)
                  Integer(0).upto(records.size) do |nRow|
                    worksheet.format_row(nRowCount + nRow + 1, table.GetRowHeight(row)/5.7, f_row)
                  end
                  nRowCount += records.size
                end
			end
			
			hidecols = 0
			Integer(0).upto(table.GetColumnCount()-1) do |col|
			   if table.IsColHidden(col)
			     hidecols += 1
			     next
			   end
			   worksheet.format_column(col-hidecols, table.GetColWidth(col)/27.5, f_row)
			end
			formats = Hash.new
			for align in ['left', 'center', 'right', 'merge']
			 formats[align] = Hash.new
			 
			 format1 = workbook.add_format(:color=>"black")
			 format1.num_format = "0.00"  
			 format1.align = align
			 format1.top = format1.bottom = format1.left = format1.right = 1          
			 formats[align]['format1'] =  format1
			
			 format2 = workbook.add_format(:color=>"black")
			 format2.num_format = "0.00"  
			 format2.align = align
			 format2.top = format2.bottom = format2.left = format2.right = 1
			 format2.bg_color = "silver"
			 formats[align]['format2'] =  format2
			
			 format3 = workbook.add_format(:color=>"black")
			 format3.num_format = "0.00" 
			 format3.align = align
			 format3.top = format3.bottom = format3.left = format3.right = 1     
			 format3.bottom = 0   
			 formats[align]['format3'] =  format3	
			
			 format4 = workbook.add_format(:color=>"black")
			 format4.num_format = "0.00"  
			 format4.align = align
			 format4.top = format4.bottom = format4.left = format4.right = 1
			 format4.bg_color = "silver"
			 format4.bottom = 0   	
			 formats[align]['format4'] =  format4
			
			 format5 = workbook.add_format(:color=>"black")
			 format5.num_format = "0.00" 
			 format5.align = align
			 format5.top = format5.bottom = format5.left = format5.right = 1
			 format5.right = 0
			 formats[align]['format5'] =  format5
			
			 format6 = workbook.add_format(:color=>"black")
			 format6.num_format = "0.00" 
			 format6.align = align
			 format6.top = format6.bottom = format6.left = format6.right = 1
			 format6.bg_color = "silver"
			 format6.right = 0
			 formats[align]['format6'] =  format6
			
			 format7 = workbook.add_format(:color=>"black")
			 format7.num_format = "0.00" 
			 format7.align = align
			 format7.top = format7.bottom = format7.left = format7.right = 1
			 format7.bottom = 0   
			 format7.right = 0
			 formats[align]['format7'] =  format7
			
			 format8 = workbook.add_format(:color=>"black")
			 format8.num_format = "0.00" 
			 format8.align = align
			 format8.top = format8.bottom = format8.left = format8.right = 1
			 format8.bg_color = "silver"
			 format8.bottom = 0   
			 format8.right = 0
			 formats[align]['format8'] =  format8
			
			 format9 = workbook.add_format(:color=>"black")
			 format9.num_format = "0.00" 
			 format9.align = align
			 format9.top = format9.bottom = format9.left = format9.right = 1
			 format9.bottom = 0   
			 format9.right = 0
			 format9.left = 0   
			 format9.top = 0
			 formats[align]['format9'] =  format9
			
			 format10 = workbook.add_format(:color=>"black")
			 format10.num_format = "0.00" 
			 format10.align = align
			 format10.top = format10.bottom = format10.left = format10.right = 1
			 format10.bg_color = "silver"
			 format10.bottom = 0   
			 format10.right = 0
			 format10.left = 0   
			 format10.top = 0
			 formats[align]['format10'] =  format10
			
			 format11 = workbook.add_format(:color=>"black")
			 format11.num_format = "0.00" 
			 format11.align = align
			 format11.top = format11.bottom = format11.left = format11.right = 1     
			 format11.bottom = 0  
			 format11.top = 0  
			 formats[align]['format11'] =  format11
			 
			 format12 = workbook.add_format(:color=>"black")
			 format12.num_format = "0.00" 
			 format12.align = align
			 format12.top = format12.bottom = format12.left = format12.right = 1    
			 format12.bg_color = "silver"
			 format12.bottom = 0  
			 format12.top = 0  
			 formats[align]['format12'] =  format12
			end        	  	  	
			
			
			     
			#写入单元格数据
			nRowCount = 0
			Integer(0).upto(table.GetRowCount()-1) do |row|
			   next if table.IsRowHidden(row)
			   hidecols = 0
			   
			   logicRow = table.PhyRowToLogicRow(row+1)
               
			   #如果是浮动表，并且此行是浮动行，则需要读取浮动行明细记录
               records = nil
               if table.IsFloatTable() && table.IsFloatTemplRow(row)  && session
                 require "Util"
                 records = Util.GetFloatData(session[:task].strid, table.GetTableID(), logicRow, session[:unitid], session[:tasktime], 1, 50000)
               end
               
               nRow = 0
               while nRow==0 || (records && nRow<=records.size)
    			   Integer(0).upto(table.GetColumnCount()-1) do |col|
    			     if table.IsColHidden(col)
    			       hidecols += 1
    			       next 
    			     end
    			     cell = table.GetCell(row, col)
    			     if cell.GetHoriAlign() == 0
    				    align = 'left'
    			     elsif cell.GetHoriAlign() == 1
    				    align = 'center'
    			     else
    				    align = 'right'
    			     end
    			     
    			     align = 'merge' if cell.GetCoveredScale().cy > 1
    				
    			     next if !cell.IsEffective()
    			     
    			     format_hash = formats[align]
    			     format = format_hash['format1']
    			     
    			     if table.IsEmptyRow(row) || table.IsEmptyCol(col) || !cell.IsStore()
    			       format = format_hash['format2']
    			       format = format_hash['format4'] if cell.GetCoveredScale().cy > 1
    			       format = format_hash['format6'] if cell.GetCoveredScale().cx > 1
    			       format = format_hash['format8'] if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx > 1 
    			     else
    			       format = format_hash['format3'] if cell.GetCoveredScale().cy > 1
    			       format = format_hash['format5'] if cell.GetCoveredScale().cx > 1
    			       format = format_hash['format7'] if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx > 1 
    			     end
    
                     if nRow==0
                        text = cell.GetText()
                     else
                        text = records[nRow-1][table.GetCellLabel(row, col)].to_s
                        text = EncodeUtil.change("GB2312", "UTF-8", text)
                     end
                     
    				 if cell.GetInputType() == CCell::ItComboBox && dictFactory
                       dictID = cell.GetDictName()
                       dict = dictFactory.GetDictionByID(dictID.to_s)
                       if dict                           
      				      text = EncodeUtil.change("GB2312", "UTF-8", dict.GetItemName(text))
      			       end
    			     end
    			
        			if cell.IsStore() && cell.GetDataType() == CCell::CtNumeric && cell.GetInputType()==CCell::ItEdit && text.strip.size != 0
        			    begin
        			       text = "%.#{cell.GetDecimal()}f" % text
        			    rescue
        			       text = 0
        			    end
        			    text = text.to_f
        			 end
    			 
        			 worksheet.write(nRow + nRowCount, col-hidecols, text, format)
        			     
        		     #跨行列
        		     if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx > 1
        		       Integer(row).upto(row+cell.GetCoveredScale().cy-1) do |srow|
          				 Integer(col).upto(col+cell.GetCoveredScale().cx-1) do |scol|
          				   format = format_hash['format9']
          				   next if row == srow && col == scol
          				   worksheet.write(nRowCount + srow - row, scol-hidecols, nil, format)
          				 end
        		       end
        		       next
        		     end
    			     
        		     #跨行
        		     if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx <= 1
          				 Integer(row+1).upto(row+cell.GetCoveredScale().cy-1) do |srow|
          				   if table.IsEmptyRow(row) || table.IsEmptyCol(col) || !cell.IsStore()
          				     format = format_hash['format12']
          				   else
          				     format = format_hash['format11']
          				   end
          				   worksheet.write(nRowCount + srow - row, col-hidecols, nil, format)
          				 end
        		     end
    		     
        		     #跨列
        		     if cell.GetCoveredScale().cx > 1 && cell.GetCoveredScale().cy <= 1
          				 Integer(col+1).upto(col+cell.GetCoveredScale().cx-1) do |scol|
          				   newformat = workbook.add_format(:color=>"black", :align => "merge")
          				   newformat.top = newformat.bottom = 1
          				   newformat.left = newformat.right = 0
          				   newformat.bg_color = format.bg_color
          				   if scol == table.GetColumnCount()-1
          				     newformat.right = 1
          				   end
          				   
          				   worksheet.write(nRowCount, scol-hidecols, nil, newformat)
          				 end
        		     end
    			   end
    			   
    			   nRow += 1
			   end
			   
			   nRowCount += 1
			   nRowCount += records.size  if records
			end
		end
		
		workbook.close
		"tmp/table.xls"
	end
	
	def ExportToExcel_Com(outTables, dictFactory, session, excel)
	  nFirst = 1
	  for table in outTables
		YtLog.info table.GetTableName()
		worksheet = excel.add_worksheet(EncodeUtil.change("GB2312", "UTF-8",table.GetTableName()),nFirst)  
		nFirst = 0
		nRowCount = 0
		#写入单元格数据
		Integer(0).upto(table.GetRowCount()-1) do |row|
		  next if table.IsRowHidden(row)
		  
		  logicRow = table.PhyRowToLogicRow(row+1)
		  
		  #如果是浮动表，并且此行是浮动行，则需要读取浮动行明细记录
		  nRow = 0
		  records = nil
		  if table.IsFloatTable() && table.IsFloatTemplRow(row)  && session
      		require "Util"
            records = Util.GetFloatData(session[:task].strid, table.GetTableID(), logicRow, session[:unitid], session[:tasktime], 1, 50000)
          end
          
          while nRow==0 || ( records && nRow <= records.size )
            
            p "nRow=#{nRow}"
            
    		hidecols = 0
			Integer(0).upto(table.GetColumnCount()-1) do |col|
				if table.IsColHidden(col)
				  hidecols += 1
				  next 
				end
				cell = table.GetCell(row, col)
				     
				align = 'merge' if cell.GetCoveredScale().cy > 1
					
				next if !cell.IsEffective()
			
			    fieldName = table.GetCellLabel(row, col)
			    p "fieldName=#{fieldName}"
			    if nRow==0
  				  text = cell.GetText()
  				else
  				  text = records[nRow-1][fieldName].to_s
  				end
  				p "text=#{text}"
  				
				#p "row #{row}, col #{col} text #{text}"
				if cell.GetInputType() == CCell::ItComboBox && dictFactory
				  dictID = cell.GetDictName()
				  dict = dictFactory.GetDictionByID(dictID.to_s)
				  if dict                           
				   text = EncodeUtil.change("GB2312", "UTF-8", dict.GetItemName(text))
				  end
				end
				if cell.IsStore() && cell.GetDataType() == CCell::CtNumeric && cell.GetInputType()==CCell::ItEdit && text.strip.size != 0
				 begin
				   text = "%.#{cell.GetDecimal()}f" % text
				   rescue
				   text = 0
				 end
				 text = text.to_f
				end
			
				#将对应的行列值转换成Ｅｘｃｅｌ文件的行列值
				#浏览器中单元格是从０行０列开始，Ｅｘｃｅｌ是从１行１列开始
				excelrow = nRow + nRowCount + 1
				excelcol = col-hidecols + 1
				
				if excelrow > 0 && excelcol > 0
					#设置Ｅｘｃｅｌ单元格值
					worksheet.setvalue(excelrow, excelcol, text) 
					#设置Ｅｘｃｅｌ单元格高度
					worksheet.setcellheight(excelrow,excelcol,table.GetRowHeight(row)/5.7)
					#设置Ｅｘｃｅｌ单元格宽度
					worksheet.setcellwidth(excelrow,excelcol,table.GetColWidth(col-hidecols)/27.5)
					#获取字体颜色
					color = cell.GetForeColor
					name = EncodeUtil.change("GB2312", "UTF-8",cell.GetFont.FontName)
					size = cell.GetFont.Size
					bold = cell.GetFont.Bold
					italic = cell.GetFont.Italic
					shadow = false
					strikethrough = false
					underline = cell.GetFont.Underline
					background = cell.GetBackColor    
					#判断单元格格式,进行设置背景色，在Ｅｘｃｅｌ中，15(12632256)代表灰色２(16777215)代表白色	     
					if table.IsEmptyRow(row) || table.IsEmptyCol(col) || !cell.IsStore()
					   if background == 16777215
					   	   background = 12632256
					   end
					end
					                       
					worksheet.setcellfont(excelrow,excelcol,name,size,color,background,bold,italic,shadow,strikethrough,underline)
			               	
					#是否自动折行
					wraptext = false
					if cell.IsWordBreak()
					  wraptext = true
					end
					#设置水平对齐方式
					horialign = cell.GetHoriAlign()
					if horialign == 0
					  #left
					  horizontalalignment = 2
					elsif horialign == 1
					  #center
					  horizontalalignment = 3
					else
					  #right
					  horizontalalignment = 1
					end
			               
				   #设置垂直对齐方式
				   vertalign =  cell.GetVertAlign()
				   if vertalign == 0
				      #top
				      verticalalignment = 1
				   elsif vertalign == 1
				      #center
				      verticalalignment = 3
				   else
				      #bottom
				      verticalalignment = 2
				   end
				                  
				   orientation = false
				   addIndent = 0
				   indentlevel = 0
				   shrinktofit = cell.GetFont.StrikeThrough
				   readingorder = 1
				   mergecells = false
				   worksheet.setcellformat(excelrow,excelcol,horizontalalignment,verticalalignment,wraptext,orientation,addIndent,indentlevel,shrinktofit,readingorder,mergecells)
				   
				   #colorindex = 24
				   pattern = 1
				   patterncolorindex = 1
				   worksheet.setcellcolor(excelrow,excelcol,background,pattern,patterncolorindex)
				end 
						
				srow = excelrow + cell.GetCoveredScale().cy - 1
				scol = excelcol + cell.GetCoveredScale().cx - 1
				#跨行列
				if cell.GetCoveredScale().cy > 1 && cell.GetCoveredScale().cx > 1
				    worksheet.setcellmergecells(excelrow,excelcol,excelrow + cell.GetCoveredScale().cy - 1,excelcol + cell.GetCoveredScale().cx - 1)
#					Integer(row).upto(row + cell.GetCoveredScale().cy - 1) do |srow|
#						Integer(col).upto(col + cell.GetCoveredScale().cx - 1) do |scol|
#							worksheet.setcellmergecells(excelrow,excelcol,srow + 1,scol - hidecols + 1)
#						end
#					end
					next
				end
						     
				#跨行
				if cell.GetCoveredScale().cy > 1
				    worksheet.setcellmergecells(excelrow,excelcol,excelrow + cell.GetCoveredScale().cy - 1,excelcol)
#					Integer(row + 1).upto(row+cell.GetCoveredScale().cy - 1) do |srow|
#						worksheet.setcellmergecells(excelrow,excelcol,srow + 1,excelcol)
#					end
				end
				
				#跨列
				if cell.GetCoveredScale().cx > 1
				    worksheet.setcellmergecells(excelrow,excelcol,excelrow,excelcol + cell.GetCoveredScale().cx - 1)
#					Integer(col + 1).upto(col + cell.GetCoveredScale().cx - 1) do |scol|
#						worksheet.setcellmergecells(excelrow,excelcol,excelrow,scol - hidecols + 1)
#					end
				end	
				bordercount = 3     
				linestyle = 7
				color = 1  
				#线宽 
				linewidth = 2
			
				Integer(0).upto(bordercount) do |index|               
					#Ｅｘｃｅｌ线型1.无线,2.点线,3,7.直线                 
					#浏览器单元格０无线，１直线，２直线加粗，３直线加粗，４直线加粗
					#Ｅｘｃｅｌ线性颜色1.自动,2.无线
					nindex = index + 1
					if index == 1
						#left
						linestyle = 7
						color = 1  
						#p cell.GetLeftBorder
					elsif index == 2
						#right
						linestyle = 7
						color = 1  
						#p cell.GetRightBorder
					elsif index == 3
						#top
						linestyle = 7
						color = 1  
						#p cell.GetTopBorder
					else
						#bottom
						linestyle = 7
						color = 1  
						#p cell.GetBottomBorder
					end                 
					worksheet.setcellborderlinestye(excelrow,excelcol,srow,scol,nindex,linestyle,color,linewidth)
					next
				end 	
			 end
             
             nRow += 1
           end
           
           nRowCount += 1
           nRowCount += records.size if records
  		  end		
        end
      #excel.show 
      excel.saveas(Dir.getwd + "/tmp", "table.xls")
	  excel.close()
	  "tmp/table.xls"
	end
end
