$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'win32ole'   
module WIN_Excel   
    class WorkBook   
        #xlEdge   
        #xlEdgeBottom =9    
        #xlEdgeLeft  = 7    
        #xlEdgeRight = 10    
        #xlEdgeTop  = 8    
        #xlColor   
        #xlColorBlank = 1   
        #xlColorWhite =2   
        #xlColorRed = 3   
        #xlColorGreen =10   
        #xlColorBlue =5   
        #xlColorYellow =6   
        #xlColorPurple = 7 # zi se   
        #xlColorCyan =8 #qing se   
        #xlBgColorYellow =19   
        #xlBgColorCyan =20   
        #xlBgColorPurple =24   
        #xlDefaultLineStyle = 1    
        @@worksheets_name =[]   
        def initialize(encoding="GB2312")   
            @excel = WIN32OLE.new("excel.application") 
            @excel.visible = FALSE   
            @workbook = @excel.Workbooks.Add()   
            #@style_id   = 0   
            @encoding = encoding   
            create_style   
        end   
        def add_worksheet(name,nFirst)   
            @@worksheets_name << name   
	    	worksheet = @workbook.Worksheets.Add(nil,@workbook.Worksheets(@workbook.WorkSheets.Count)) 
	    	if nFirst == 1			
				@workbook.Worksheets(1).Delete 
	    	end
            worksheet.Activate   
            worksheet.name = name   
            return WorkSheet.new(worksheet)    
        end  
         
        def show   
            @excel.visible = TRUE   
        end   
	    def saveas(path,filename)	
	       begin
	         name = path + "/" + filename
	         Dir.foreach(path){|x|
	           if x == filename
		        File.delete(name)
	           end
	         }
	         @workbook.SaveAs(name)
	       rescue
	       saveas(path,filename + ".xls")
	       ensure
	       end
	    end
        def close   
            @workbook.Close(0)   
            @excel.quit()   
        end   
        def create_style   
            sty=@workbook.Styles.Add('NormalStyle')   
            sty.Font.Size = 12   
            sty.Borders(7).LineStyle=1   
            sty.Borders(8).LineStyle=1   
            sty.Borders(9).LineStyle=1   
            sty.Borders(10).LineStyle=1   
   
            sty=@workbook.Styles.Add('TitleStyle')   
            sty.Font.Size = 16   
            sty.Font.Bold =true   
            sty.Font.ColorIndex =3   
            #sty.Interior.ColorIndex = 20   
        end   
    end   
    #worksheet   
    class WorkSheet   
        IMAGE_ROW_NUM = 56   
        @@worksheets_name =[]   
        def initialize(worksheet)   
            @row_count = 1   
            @worksheet = worksheet   
        end   
        def add_space_line(n=1)   
            return if n<1
            @row_count +=n   
        end   
        def add_title(name)   
            add_space_line   
            add_row.add_cell(name,false,"TitleStyle")   
        end   
        def add_row()   
            @current_row = Row.new(@worksheet,@row_count)   
            @row_count +=1   
            return  @current_row   
        end   
        def current_row   
            return  @current_row   
        end   
        def add_image(image_path)   
            if not File.exist?(image_path)   
                return   
            end   
            add_space_line 1   
            add_row   
            cell_name=current_row.first_cell   
            @worksheet.Range(cell_name).Select   
            @worksheet.Pictures.Insert(image_path)   
            add_space_line  IMAGE_ROW_NUM   
        end   
	def setvalue(row,col,value)  
	    if value == nil
		value = ""
	    end
	    @worksheet.Cells(row,col).value2 = value.to_s	    
	end
	def setcellheight(row,col,value)
	    if value == nil
		value = 0
	    end
	    #@worksheet.Rows(row).RowHeight = value
	    @worksheet.Cells(row,col).RowHeight = value
	end
	def setcellwidth(row,col,value)
	    if value == nil
		value = 0
	    end
	    #@worksheet.Rows(col).ColumnWidth = value	
	    @worksheet.Cells(row,col).ColumnWidth = value
	end

	##########���õ�Ԫ��߿�ķ��##############
	def setcellborderlinestye(beginrow,begincol,endrow,endcol,index,linestyle,color,linewidth)
	    #���ñ߿�ķ��index(�߿�)��Ϊ���� XlBordersIndex ��֮һ��xlDiagonalDown��xlDiagonalUp��xlEdgeBottom��xlEdgeLeft��xlEdgeRight��xlEdgeTop��xlInsideHorizontal �� xlInsideVertical
	    if index == nil
		index = 1
	    end		

	    #linestyle���߸�ʽ������������XlLineStyle ��Ϊ���� XlLineStyle ��֮һ�� xlContinuous default ��xlDash ��xlDashDot ��xlDashDotDot  ��xlDot ��xlDouble ��xlLineStlyeNone ��xlSlantDashDot ��xlLineStlyeNone 
	    if linestyle == nil
		linestyle = 7
	    end
	    @worksheet.Range(@worksheet.Cells(beginrow,begincol),@worksheet.Cells(endrow,endcol)).Borders(index).LineStyle = linestyle

	    #linewidth
	    if linewidth == nil
		linewidth = 2
	    end
	    @worksheet.Range(@worksheet.Cells(beginrow,begincol),@worksheet.Cells(endrow,endcol)).Borders(index).Weight = linewidth

	    #color(�߿���ɫ)
	    if color == nil
		color = 15
	    end
	    @worksheet.Range(@worksheet.Cells(beginrow,begincol),@worksheet.Cells(endrow,endcol)).Borders(index).ColorIndex = color
	end

	##########���õ�Ԫ���������ƣ���С����ɫ����Ϣ###########
	def setcellfont(row,col,name,size,color,background,bold,italic,shadow,strikethrough,underline)
	    #name������������
	    if name == nil
		name = "����_GB2312"
	    end
	    @worksheet.Cells(row,col).Font.Name = name

	    #Size���������С
	    if size == nil
		size = 11
	    end
	    @worksheet.Cells(row,col).Font.Size = size

	    #Color�����������ɫ
	    if color == nil
		color = 0
	    end
	    @worksheet.Cells(row,col).Font.Color = color

	    #BackGround��������ı�������Ҫȡ����ֵxlBackgroundAutomatic��xlBackgroundOpaque �� xlBackgroundTransparent��
	    if background == nil
		background = 0
	    end
	    #@worksheet.Cells(row,col).Font.Background = background

	    #Bold���������Ƿ�Ӵ֣�true,false��
	    if bold == nil
		bold = 0
	    end
	    @worksheet.Cells(row,col).Font.Bold = bold

	    #Italic�����Ƿ���Ϊ��б��true,false��
	    if italic == nil
		italic = 0
	    end
	    @worksheet.Cells(row,col).Font.Italic = italic

	    #Shadow�����Ƿ�Ϊ����Ӱ���壨true,false��
	    if shadow == nil
		shadow = 0
	    end
	    @worksheet.Cells(row,col).Font.Shadow = shadow

	    #Strikethrough�����м��Ƿ���һ��ˮƽɾ���ߣ�true,false��
	    if strikethrough == nil
		strikethrough = 0
	    end
	    @worksheet.Cells(row,col).Font.Strikethrough = strikethrough

	    #Underline����Ӧ����������»�������xlUnderlineStyleNone ��xlUnderlineStyleSingle ��xlUnderlineStyleDouble��xlUnderlineStyleSingleAccounting��xlUnderlineStyleDoubleAccounting
	    if underline == nil
		underline = 0
	    end
	    @worksheet.Cells(row,col).Font.Underline = underline	

	end

	#########���õ�Ԫ���ʽ############
	def setcellformat(row,col,horizontalalignment,verticalalignment,wraptext,orientation,addIndent,indentlevel,shrinktofit,readingorder,mergecells)
	    #����ˮƽ�����ʽ	
	    if horizontalalignment == nil
		horizontalalignment = 0
	    end
	    @worksheet.Cells(row,col).HorizontalAlignment = horizontalalignment

	    #���ô�ֱ�����ʽ
	    if verticalalignment == nil
		verticalalignment = 0
	    end
	    @worksheet.Cells(row,col).VerticalAlignment = verticalalignment

	    #���õ�Ԫ�������Ƿ��Զ�����
	    if wraptext == nil
		wraptext = false
	    end
	    @worksheet.Cells(row,col).WrapText = wraptext

	    #���õ�Ԫ�����ݷ���
	    if orientation == nil
		orientation = 0
	    end
	    @worksheet.Cells(row,col).Orientation = orientation

	    #���õ�Ԫ�������Ƿ�������
	    if addIndent == nil
		addIndent = false
	    end
	    @worksheet.Cells(row,col).AddIndent = addIndent

	    #���õ�Ԫ�������������~�����Ŀ
	    if indentlevel == nil
		indentlevel = 0
	    end
	    @worksheet.Cells(row,col).IndentLevel = indentlevel

	    #���õ�Ԫ�������Զ�����Ϊ�ʵ��ߴ�����Ӧ�����п�
	    if shrinktofit == nil
		shrinktofit = false
	    end
	    @worksheet.Cells(row,col).ShrinkToFit = shrinktofit

	    #���õ�Ԫ������ָ��������Ķt���
	    if readingorder == nil
		readingorder = 0
	    end
	    @worksheet.Cells(row,col).ReadingOrder = readingorder

	    #�����������ʽ��ϲ���Ԫ��true,false��
	    if mergecells == nil
		mergecells = false
	    end
	    @worksheet.Cells(row,col).MergeCells = mergecells
	end

	###########���õ�Ԫ�����ɫ###############
	def setcellcolor(row,col,colorindex,pattern,patterncolorindex)
	    #����
	    if colorindex == nil
		colorindex = 0
	    end
	    @worksheet.Cells(row,col).Interior.Color = colorindex

	    if pattern == nil
		pattern = 0
	    end
	    @worksheet.Cells(row,col).Interior.Pattern = pattern

	    if patterncolorindex == nil
		patterncolorindex = 0
	    end	    	
	    @worksheet.Cells(row,col).Interior.PatternColorIndex = patterncolorindex
	end
	###########�ϲ���Ԫ��###############
	def setcellmergecells(beginrow,begincol,endrow,endcol)
	    @worksheet.Range(@worksheet.Cells(beginrow,begincol),@worksheet.Cells(endrow,endcol)).MergeCells = true
	end
    end   
    #row   
    class Row   
        FILL_TYPE = 4   
        @@cell_map =["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]   
        def initialize(worksheet,row_id)   
            @row_id     =row_id   
            @cell_count=0   
            @worksheet = worksheet   
        end   
        def curent_cell   
            return  cell_name(@cell_count)   
        end   
        def first_cell   
            return cell_name(0)   
        end   
        def add_cell(value,auto_fit = false,style = "NormalStyle")   
            range = @worksheet.Range(cell_name(@cell_count))   
            range['Value'] = value.to_s;   
            range['Style']=style   
            range.Columns.AutoFit if auto_fit   
            @cell_count +=1   
        end   
        def cell_name(index)  

            second = index % 26   
            first = (index - second) / 26   
            if first == 0   
                return @@cell_map[second]+@row_id.to_s     
            end   
            first -=1   
            return @@cell_map[first]+@@cell_map[second]+@row_id.to_s   
        end   
        def set_cell(index,value,auto_fit = false,style = "NormalStyle")   
            range=@worksheet.Range(cell_name(index))   
            range['Value'] = value;   
            range['Style']=style   
            range.Columns.AutoFit if auto_fit          
        end   
    end   
end   