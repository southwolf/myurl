require "Table"
require "StyleManager"
require "Diction"
require "iconv"
require "Size"
require "Style"
require "Script"
require 'rexml/document'
require "EncodeUtil"
require "Cell"
require "spreadsheet/excel"
require "TableToPDF"
require "TableToExcel"

include Spreadsheet
include REXML

class XMLHelper
    attr_reader :parameters, :tables, :dictionFactory, :script
    
    #将表导出到Excel
    #outTables : 数组，默认为nil，数组元素是CTable表,如果为空则取本对象的表数组
    #dictFactory : 代码字典工厂，可以将代码型单元格的字符串转变为含义
    def ExportToExcel(outTables = nil, dictFactory = nil)        
        excel = TableToExcel.new
        excel.ExportToExcel(outTables || @tables, dictFactory)
	end
    
    #将表导出到PDF
    #outTables : 数组，默认为nil，数组元素是CTable表,如果为空则取本对象的表数组
    #dictFactory : 代码字典工厂，可以将代码型单元格的字符串转变为含义
    def ExportToPDF(outTables = nil, outDictFactory = nil)		
		outTables = tables if outTables == nil
        pdf = PDF.new
		pdf.Open
		pdf.extend(PDF_Chinese)
		pdf.AddGBFont('simsun', EncodeUtil.change('GB2312', 'UTF-8', '宋体')); 
		pdf.AddGBFont('simhei', EncodeUtil.change('GB2312', 'UTF-8', '黑体')); 
		pdf.AddGBFont('simkai', EncodeUtil.change('GB2312', 'UTF-8', '楷体')); 
		pdf.AddGBFont('sinfang',EncodeUtil.change('GB2312', 'UTF-8', '仿宋')); 
		pdf.SetFont('simsun', '', 9);
		pdf.write_tables(outTables, outDictFactory)
	    pdf.Output('tmp/table.pdf')
	    
	    'tmp/table.pdf'	  
    end
    
    #从文件读取表模型，从XML文件读取表模型有两种方式，纯Ruby方式和Windows COM组件方式。具体方式视$OS全局配置方式（"UNIX"或"WINDOWS"）而定
    #src : 文件路径
    def ReadFromFile(src)
     if $OS == "UNIX"
        Ruby_ReadFromXMLFile(src)
      elsif $OS == "WINDOWS"
       MS_ReadFromXMLFile(src)
      end
    end
    
    #从字符串读取表模型，从XML文件读取表模型有两种方式，纯Ruby方式和Windows COM组件方式。具体方式视$OS全局配置方式（"UNIX"或"WINDOWS"）而定
    #src : 传入GB2312编码的字符串
    def ReadFromString(src)
      if $OS == "UNIX"        
        src = EncodeUtil.change("UTF-8", "GB2312", src)
        Ruby_ReadFromXMLString(src)
      elsif $OS == "WINDOWS"
        MS_ReadFromXMLString(src)
      end
    end
    
    #将表模型写入XML，返回一个字符串。采用纯Ruby库完成此功能。
    #tables : CTable表集合
    #dictFactory : 代码字典工厂
    #script : 脚本类
    #prop : 任务属性
    def REXML_WriteToXML(tables, dictFactory, script, prop)
        doc = Document.new("<YotopBook></YotopBook>")
        parameters = doc.root.add_element(Element.new('Parameters'))
        prop.each do |key, value|
           parameter = parameters.add_element(Element.new('Parameter'))
           keynode = parameter.add_element(Element.new('Key'))
           keynode.text = key
           valuenode = parameter.add_element(Element.new('Value'))
           valuenode.text = value
        end
        
        styles = doc.root.add_element(Element.new('Styles'))
        manageArray = Array.new
        tables.each {|table|
            manageArray<<table.GetStyleManager if !manageArray.include?(table.GetStyleManager)
        }
        for manager in manageArray
            for style in manager.m_Styles
                stylenode = styles.add_element(Element.new('Style'))
                style.OutputXML(stylenode)
            end
        end
        
        for table in tables
            tablenode = doc.root.add_element(Element.new('Table'))
            table.OutputXML(tablenode)
        end
        
        dictions = dictFactory.GetAllDictions()
        #print "write dictions\n"
        for dict in dictions
            dictnode = doc.root.add_element(Element.new('Dictionary'))
            dict.OutputXML(dictnode)
        end
        
        if script
            scriptnode = doc.root.add_element(Element.new('Scripts'))
            script.OutputXML(scriptnode)
        end
        
        doc.xml_decl().nowrite()
        #输出
        xmlstr = ''
        YtLog.info Time.new, 'before write xml'
        doc.write(Output.new(xmlstr, "UTF-8"), 1)
        xmlstr = xmlstr.sub("<?xml version='1.0'?>", "")
        #xmlstr = EncodeUtil.change("GB2312", "UTF-8", xmlstr)
        
        YtLog.info Time.new, 'after write xml'
        xmlstr
    end
    
    #将表模型转成可录入的HTML，返回字符串
    #table : CTable表对象
    #dicFactory : 代码字典工厂
    #*args : hash变量，可一次性传入多个标志，如TableToEditHTML(table1, factory1, {:script=>script, :readonly=>true})
    #所有标志如下：
    #:script => 脚本
    #:title => HTML标题
    #:only_table_tag => true or false，如果为true，则不产生<HTML><BODY>..节点，直接从<Table>节点开始
    #:readonly => 生成只读页面
    #:encoding => "GB2312" 或"utf-8"，默认是"utf-8"
    #:record => ActiveRecord::Base对象，如果表单元格名称与ActiveRecord::Base对象某个字段名称一致，则生成的<td>单元格值取ActiveRecord::Base对象的值
    #:lines_per_page => 每页显示多少行，用于分页场合，默认20行
    #:page => 当前显示第几页，用于分页场合，默认为1
    #:show_all_page => 是否显示所有页，默认为true
    #:float_record => 浮动行记录，是一个ActiveRecord::Base对象数组
    #:currency => 金额单位
    #:table_class => 构造<table class='table_class'>，方便进行页面布局
    def TableToEditHTML(table, dicFactory=nil, *args)
        return if !table
        
        dictFactory = @dictionFactory if !dictFactory
        args = args[0]
        script = args[:script]
        title = args[:title] || ""
        onlytabletag = args[:only_table_tag]
        onlytabletag = true if !args.keys.include?(:only_table_tag)
        readonly = args[:readonly]
        readonly = true if !args.keys.include?(:readonly)
        encoding = args[:encoding] || "utf-8"
        record = args[:record]
        
        linesperpage = args[:lines_per_page] || 20
        page = args[:page] || 1
        showallpage = args[:show_all_page] || true
        float_hash = args[:float_record]
        currency = args[:currency]          #金额单位
        table_class = args[:table_class]
        output_dict = args[:output_dict]
        output_dict = true if !args.keys.include?(:output_dict)
        
        result = ""        
        if !onlytabletag
            
            result << "<html>\n\t<head>\n\t<title>#{title.to_s}</title>\n"
            result << "\t<script language='javascript' src='PopupCalendar.js' ></script>\n"
        
            result << "\t<head>\n"
            #result << "\t\t<link rel='stylesheet' type='text/css' href='main.css'>\n"
            result << StyleToHTML(table, 'gb2312')
            result << "\t</head>\n"
            result << "\t\t<body>\n"
            #p readonly
            if !readonly
                result << EncodeUtil.change(encoding, "UTF-8", '<script >

var oCalendarEn=new PopupCalendar("oCalendarEn");	//初始化控件时,请给出实例名称如:oCalendarEn
oCalendarEn.Init();
var oCalendarChs=new PopupCalendar("oCalendarChs");	//初始化控件时,请给出实例名称:oCalendarChs
oCalendarChs.weekDaySting=new Array("日","一","二","三","四","五","六");
oCalendarChs.monthSting=new Array("一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月");
oCalendarChs.oBtnTodayTitle="今天";
oCalendarChs.oBtnCancelTitle="取消";
oCalendarChs.Init();
</script>') + "\n"
                
            end
        
            result << "\t\t<form id='#{table.GetTableID().downcase()}' name='#{table.GetTableID().downcase()}'>\n"
        end
        
        #输出代码字典
        dictions = dicFactory.GetAllDictions
        for diction in dictions
           result << EncodeUtil.change("GB2312", "UTF-8", "\t\t<div id = 'dict_#{diction.ID}' style='position:absolute;width:250px;max-height:300px;display:none;overflow:hidden;background-color=#ccccff;z-index:2;'>")
           result << EncodeUtil.change("GB2312", "UTF-8", "\n\t\t<table width=250px bgcolor='#0066cc'>
                        <tr id=\"handle\" class=\"exebar\" %>
                          <td align=center width=80%>选择代码字典</td>
                          <td align=right width=20%><a href=\"javascript:Element.hide('dict_#{diction.ID}');$('dict_#{diction.ID}').cell.focus();\">关闭</a></td>
                        </tr>
                    </table>\n")
           result << "\t\t<div style='overflow:auto;height:280px;SCROLLBAR-FACE-COLOR: #CCCCCC;SCROLLBAR-HIGHLIGHT-COLOR: #AAAAAA; SCROLLBAR-SHADOW-COLOR: #AAAAAA; SCROLLBAR-3DLIGHT-COLOR: #AAAAAA; 
						  SCROLLBAR-ARROW-COLOR: #AAAAAA; 
						  SCROLLBAR-TRACK-COLOR: #AAAAAA;
						  SCROLLBAR-DARKSHADOW-COLOR: #AAAAAA;'>\n"
           if diction.GetRootItems.size > 0
               result << "\t\t<script LANGUAGE='JavaScript'>\n"
               for item in diction.GetRootItems
                 result << "\t\tvar tree_#{diction.ID}_#{item} = new WebFXTree('#{EncodeUtil.change('GB2312', 'UTF-8', diction.GetItemName(item))}');\n"
                 result << "\t\ttree_#{diction.ID}_#{item}.action = \"javascript:select_cellvalue(#{item}, '#{EncodeUtil.change('GB2312', 'UTF-8', diction.GetItemName(item))}','dict_#{diction.ID}')\";\n"
                 children = diction.GetChildren(item)
                 for child in children
                   result << "var node#{child} = new WebFXTreeItem('#{EncodeUtil.change('GB2312', 'UTF-8', diction.GetItemName(child))}');\n"
                   result << "node#{child}.action = \"javascript:select_cellvalue(#{child}, '#{EncodeUtil.change('GB2312', 'UTF-8', diction.GetItemName(child))}','dict_#{diction.ID}')\";\n"
                   result << "tree_#{diction.ID}_#{item}.add(node#{child});\n"
                 end
                 result << "\t\tdocument.write(tree_#{diction.ID}_#{item});\n"
               end           
               result << "\t\t</script>\n"
           else
              YtwgAnontable.set_table_name(diction.Name)
              YtwgAnontable.set_primary_key(:id)
              YtwgAnontable.reset_column_information
              dicts = YtwgAnontable.find(:all)
              text = "<script LANGUAGE='JavaScript'>"
              for dict in dicts
                text << "var tree_#{dict.id} = new WebFXTree('#{EncodeUtil.change('GB2312', 'UTF-8', dict.name)}');"
                text << "\ntree_#{dict.id}.action = \"javascript:select_cellvalue(#{dict.id}, '#{EncodeUtil.change('GB2312', 'UTF-8', dict.name)}','dict_#{diction.ID}')\";\n"
                text << "document.write(tree_#{dict.id});"
              end
              text << "</script>"
             result << text
           end
           result << "\t\t</div>\n"
           result << "\t\t</div>\n"
        end
        
        
        #输出表格
        result << "\t\t<table id='table_#{table.GetTableID()}' style='width:#{cs(table.GetTotalWidth())}mm' class='#{table_class || "yotopTable"}'>\n"
        
        Integer(0).upto(table.GetColumnCount()-1) do |col|
          next if table.IsColHidden(col)
          result << "\t\t\t<col style=\"width:#{cs(table.GetColWidth(col))}mm\"></col>\n"
        end
        
        
        #输出所有行
        Integer(0).upto(table.GetRowCount()-1) do |row|
#           if table.IsFloatTemplRow(row)
#              result << "\t\t\t<div id='float#{table.PhyRowToLogicRow(row+1)}'>\n"
#           end

		   next if table.IsRowHidden(row)
           
           result << AddAnEditHTMLRow(table, row, dicFactory, readonly, record, false, currency) 
           if table.IsFloatTemplRow(row) && float_hash
             float_records = float_hash[table.PhyRowToLogicRow(row+1)]
             next if !float_records
             
             index = 1
             for float_record in float_records
              result << AddAnEditHTMLRow(table, row, dicFactory, readonly, float_record, true, currency, index) 
              index += 1
             end
           end
        end        
        
        result << "\t\t</table>\n"
        
        if !readonly
#            result << "<button onclick='audit()'>#{EncodeUtil.change("GB2312", "UTF-8", '提交')}</button>
#                        <button type='reset'>#{EncodeUtil.change("GB2312", "UTF-8", '清空')}</button>"
#            result << "\t\t</form>\n"
            result << "\t\t<script>\n
            function calc()
            {
                with (#{table.GetTableID().downcase()})
                {
                    #{EncodeUtil.change("GB2312", "UTF-8", script.getCalcScript(table.GetTableID()))}
                }
            }
            function a(expr, str, cell)
            {
            	if (!expr)
            	{
            		alert(str);
            		return false
            	}            	
            	return true
            }
            function audit()
            {
            	with(#{table.GetTableID().downcase()})
            	{
                    #{EncodeUtil.change("GB2312", "UTF-8",script.getAuditScript(table.GetTableID()))}
            	}
            	#{table.GetTableID().downcase}.submit();
            }
            </script>\n" if script

        end
        
        if !onlytabletag
            result << "\t\t</body>\n</html>"
        end
        
        if encoding.downcase == "utf-8"        	
            begin
            	result = EncodeUtil.change("UTF-8", "GB2312", result)
            rescue Exception=>err
              p err.backtrace
            end
        else
            result        
        end
        
        result
    end
    
    #从XML文件读取表模型，调用微软的"Msxml2.DOMDocument.6.0"COM组件
    def MS_ReadFromXMLFile(src)
        require 'win32ole'
        xml = WIN32OLE.new("Msxml2.DOMDocument.6.0")
        xml.preserveWhiteSpace = true
        xml.Load(src)
        MS_ReadFromXML(xml)
    end
    
    #从XML字符串读取表模型，调用微软的"Msxml2.DOMDocument.6.0"COM组件
    def MS_ReadFromXMLString(src)
        require 'win32ole'
        xml = WIN32OLE.new("Msxml2.DOMDocument.6.0")
        xml.preserveWhiteSpace = true
        xml.loadXML(src)
        MS_ReadFromXML(xml)
    end
    
    #从XML文件读取表模型，调用纯Ruby库
    def Ruby_ReadFromXMLFile(src)
        doc =  Document.new(File.new(src, 'r') )
        Ruby_ReadFromXML(doc)
    end
    
    #从XML文件读取表模型，调用纯Ruby库
    def Ruby_ReadFromXMLString(src)
        doc =  Document.new(EncodeUtil.change("GB2312", "UTF-8", src))
        Ruby_ReadFromXML(doc)
    end
    
    #将Style对象转成HTML，返回字符串
    #table : CTable表对象
    def StyleToHTML(table, encoding='UTF-8')
        result = ""            
        result <<"\t\t\t<style  type='text/css'>\n"
        styles = table.GetStyleManager().m_Styles
        result << ".yotopTable
{
    border-width: 1px;
    border-style: solid;
    border-color: #000000 #000000 #000000 #000000 ;
    border-collapse: collapse;
    table-layout: fixed;
}"
        for style in styles
           result << "\t\t\t\t.style#{style.GetID}{"
           result << "font-size:#{style.GetFont().Size + 3}px; font-family:#{EncodeUtil.change("GB2312","UTF-8",style.GetFont().FontName)}; "
           result << "font-weight:bold;" if style.GetFont().Bold
           result << "color:##{'%06X' % style.GetForeColor()}; "
           lineWidth = style.GetTopBorder().LineWidth
           lineWidth = 0 if !style.GetTopBorder().bDisplay
           result << "border-top:#{lineWidth}px solid ##{'%06X' % style.GetTopBorder().LineColor}; "
           lineWidth = style.GetBottomBorder().LineWidth
           lineWidth = 0 if !style.GetBottomBorder().bDisplay
           result << "border-bottom:#{lineWidth}px solid ##{'%06X' % style.GetBottomBorder().LineColor}; "
           lineWidth = style.GetLeftBorder().LineWidth
           lineWidth = 0 if !style.GetLeftBorder().bDisplay
           result << "border-left:#{lineWidth}px solid ##{'%06X' % style.GetLeftBorder().LineColor}; "
           lineWidth = style.GetRightBorder().LineWidth
           lineWidth = 0 if !style.GetRightBorder().bDisplay
           result << "border-right:#{lineWidth}px solid ##{'%06X' % style.GetRightBorder().LineColor}; "
           result << "background-color:##{'%06X' % style.GetBackColor}; "
           if style.GetHoriAlign() == CellStyle::DT_RIGHT
             result << "text-align:right;"
           elsif style.GetHoriAlign() == CellStyle::DT_LEFT
             result << "text-align:left;"
           elsif style.GetHoriAlign() == CellStyle::DT_CENTER
             result << "text-align:center;"
           end
           result <<"}\n"
        end           
        
        
        result <<"\t\t\t</style>\n"
        result = EncodeUtil.change(encoding, 'GB2312', result) if encoding.downcase == 'utf-8'
        result
    end
    
    #输出浮动行
    #table => 表模型
    #row => 浮动模板行所在行号
    #records => 浮动行的记录，ActiveRecord::Base对象数组
    #dictFactory => 代码字典工厂
    def AddFloatHTMLRows(table, row, records, dictFactory=nil)
      result = ""
      for record in records
        result += AddAnEditHTMLRow(table, row, dictFactory, true, record)
      end
      result
    end

    private
        def MS_ReadFromXML(doc)
            @parameters = Hash.new
            @tables = Array.new
            @dictionFactory = DictionFactory.new
            @script = CTaskScript.new
            
            root = doc.documentElement
            topnodelist = root.childnodes
            Integer(0).upto(topnodelist.length-1) do |n|
                topnode = topnodelist.item(n)
                if topnode.basename == "Parameters"
                    paramsnodelist = topnode.childnodes
                    1.upto(paramsnodelist.length) do |i|
                        param = paramsnodelist.item(i-1)
                        next if param.nodeName == "#text"
                        key = ''
                        value = ''
                        keyvaluelist = param.childnodes
                        1.upto(keyvaluelist.length) do |j|
                          keynode = keyvaluelist.item(j-1)
                          next if keynode.nodeName == "#text"
                          key = EncodeUtil.change("UTF-8", "GB2312", keynode.text) if keynode.nodeName == "Key"
                          value = EncodeUtil.change("UTF-8", "GB2312", keynode.text) if keynode.nodeName == "Value"
                        end
                        @parameters[key] = value
                    end
                elsif topnode.basename == "Styles"
                    @stylemanager = StyleManager.new            
                    stylesnodelist = topnode.childnodes
                    1.upto(stylesnodelist.length) do |i|
                       stylenode = stylesnodelist.item(i-1)
                       next if stylenode.nodeName == "#text"
                       style = @stylemanager.NewStyle()
                       style.m_clrBackColor = stylenode.attributes.getnameditem('BackColor').text.delete('#').hex
                       style.m_nDataType = stylenode.attributes.getnameditem('DataType').text.hex
                       style.m_nDecimalDigits = stylenode.attributes.getnameditem('DecimalDigits').text.hex
                       style.m_clrForeColor = stylenode.attributes.getnameditem('ForeColor').text.delete('#').hex
                       style.m_nID = stylenode.attributes.getnameditem('ID').text.to_i
                       style.m_nInputType = stylenode.attributes.getnameditem('InputType').text.hex
                       style.m_bWidthCheck = stylenode.attributes.getnameditem('IsCheckWidth').text=="1"
                       style.m_bHideFormula = stylenode.attributes.getnameditem('IsHideFormula').text=="1"
                       style.m_bThousandMark = stylenode.attributes.getnameditem('IsThousandMark').text=="1"
                       style.m_bShowZero = stylenode.attributes.getnameditem('ShowZero').text=="1"
                       style.m_nTextLength = stylenode.attributes.getnameditem('TextWidth').text.to_i
                       
                       alignnodelist = stylenode.childnodes
                       1.upto(alignnodelist.length) do |j|
                        alignode = alignnodelist.item(j-1)
                        next if alignode.nodeName == "#text"
                        
                        if alignode.nodeName == "Alignment"
                          style.m_nHoriAlign = alignode.attributes.getnameditem('HoriAlign').text.to_i
                          style.m_nVertAlign = alignode.attributes.getnameditem('VertAlign').text.to_i
                          style.m_bWrapText = alignode.attributes.getnameditem('WrapText').text == "1"
                          style.m_bShrinkToFit = alignode.attributes.getnameditem('ShrinkToFit').text == "1"
                        elsif alignode.nodeName == "Borders"
                          bordersnode = alignnodelist.item(j-1)
                          bordernodelist = bordersnode.childnodes
                          Integer(0).upto(bordernodelist.length-1) do |b|
                            bordernode = bordernodelist.item(b)  
                            next if bordernode.nodeName == "#text"
                            pos = bordernode.attributes.getnameditem('Position').text.to_i
                            style.m_Borders[pos].bDisplay = bordernode.attributes.getnameditem('Display').text == "true"
                            style.m_Borders[pos].LineColor = bordernode.attributes.getnameditem('LineColor').text.delete("#").hex
                            style.m_Borders[pos].LineStyle = bordernode.attributes.getnameditem('LineStyle').text.to_i
                            style.m_Borders[pos].LineWidth = bordernode.attributes.getnameditem('LineWidth').text.to_i
                          end    
                        elsif alignode.nodeName == "Font"
                          fontnode = stylenode.childnodes.item(j-1)
                          next if fontnode.nodeName == "#text"
                          style.m_Font.Size = fontnode.attributes.getnameditem('Size').text.to_i
                          style.m_Font.FontName = EncodeUtil.change("UTF-8", "GB2312", fontnode.attributes.getnameditem('FontName').text)
                          style.m_Font.Bold = fontnode.attributes.getnameditem('Bold').text=="1"
                          style.m_Font.CharSet = fontnode.attributes.getnameditem('CharSet').text
                          style.m_Font.Underline = fontnode.attributes.getnameditem('Underline').text=="1"
                          style.m_Font.StrikeThrough = fontnode.attributes.getnameditem('StrikeThrough').text=="1"
                          style.m_Font.Italic = fontnode.attributes.getnameditem('Italic').text=="1"
                        end
                       end
                    end
                elsif topnode.basename == "Table"
                    tablenode = topnode        
                    id = tablenode.attributes.getnameditem('TableID').text
                    name = EncodeUtil.change("UTF-8", "GB2312", tablenode.attributes.getnameditem('TableName').text)
                    rowcount = tablenode.attributes.getnameditem('RowCount').text.to_i
                    colcount = tablenode.attributes.getnameditem('ColCount').text.to_i
                    table = CTable.new(@stylemanager, id, name)
                    table.OnNewTable(rowcount, colcount, 0, 0)
                    @tables<<table
                    #print "table #{id} #{name} \n"
                    
                    rowcolnodelist = tablenode.childnodes
                    Integer(0).upto(rowcolnodelist.length-1) do |i|
                        rowcolnode = rowcolnodelist.item(i)
                        if rowcolnode.basename == "Col"
                            empty = rowcolnode.attributes.getnameditem('Empty').text == "1"
                            hidden = rowcolnode.attributes.getnameditem('Hidden').text == "1"
                            width = rowcolnode.attributes.getnameditem('Width').text.to_i
                            colindex = rowcolnode.attributes.getnameditem('Index').text.to_i
                            table.SetEmptyCol(colindex) if empty
                            table.SetColHidden(colindex, hidden) #if hidden
                            table.SetColWidth(colindex, width)
                        elsif rowcolnode.basename == "Row"
                            empty = rowcolnode.attributes.getnameditem('Empty').text == "1"
                            hidden = rowcolnode.attributes.getnameditem('Hidden').text != "0"
                            height = rowcolnode.attributes.getnameditem('Height').text.to_i
                            rowindex = rowcolnode.attributes.getnameditem('Index').text.to_i
                            #print "\nrow index #{rowindex}\n"
                            table.SetEmptyRow(rowindex) if empty
                            table.SetRowHidden(rowindex, hidden)
                            table.SetRowHeight(rowindex, height)
                            cellnodelist = rowcolnode.childnodes
                            Integer(0).upto(cellnodelist.length-1) do |j|    
                                subnode = cellnodelist.item(j)
                                if subnode.basename == "Parameters"
                                	parameterlist = subnode.childnodes
                                	1.upto(parameterlist.length) do |k|                                                
                                        param = parameterlist.item(k-1)
                                        next if param.nodeName == "#text"
                                        key = ''
                                        value = ''
                                        keyvaluelist = param.childnodes
                                        1.upto(keyvaluelist.length) do |j|
                                          keynode = keyvaluelist.item(j-1)
                                          next if keynode.nodeName == "#text"
                                          key = EncodeUtil.change("UTF-8", "GB2312", keynode.text) if keynode.nodeName == "Key"
                                          value = EncodeUtil.change("UTF-8", "GB2312", keynode.text) if keynode.nodeName == "Value"
                                        end        
                                		if key == "IsFloatTemplateRow"
                                		    table.SetFloatTemplateRow(rowindex, value=="true")
                                		end
                                	end
                                end                                
                                
                                cellnode = subnode
                                next if cellnode.basename != "Cell"
                                colindex = cellnode.attributes.getnameditem('Index').text.to_i
                                cell = table.GetCell(rowindex, colindex)
                                datanodelist = cellnode.childnodes
                                1.upto(datanodelist.length) do |k|
                                  datanode = datanodelist.item(k-1)
                                  next if datanode.nodeName == "#text"
                                  if datanode.basename == "Data"
                                  	cell.SetText(datanode.text)
                                  end
                                end
                                
                                
                                cell.SetDescription(EncodeUtil.change("UTF-8", "GB2312", cellnode.attributes.getnameditem('Description').text))
                                #cell.DictDisplayMode(cellnode.attributes.getnameditem('DictDisplayMode').text.to_i)
                                cell.SetDictName(cellnode.attributes.getnameditem('DictName').text)
                                #cell.SetCoveredScale(cellnode.attributes.getnameditem('DictName').text == "1")
                                cell.SetAttribute(CCell::TC_CF_STORE, cellnode.attributes.getnameditem('IsStoreDB').text == "1")
                                cell.SetAttribute(CCell::TC_CF_SUM, cellnode.attributes.getnameditem('IsSum').text == "1")
                                cell.SetAttribute(CCell::TC_CF_PRECISION, cellnode.attributes.getnameditem('IsConvertPrecision').text == "1")
                                x = cellnode.attributes.getnameditem('MergeAcross').text.to_i
                                y = cellnode.attributes.getnameditem('MergeDown').text.to_i
                                sz = CSize.new(x,y)
                                cell.SetCoveredScale(sz)
                                
                                #设置其他单元格无效
                                Integer(rowindex+1).upto(rowindex+y-1) do |srow|
                                  other = table.GetCell(srow, colindex)
                                  other.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
                                end
                                Integer(colindex+1).upto(colindex+x-1) do |scol|
                                  other = table.GetCell(rowindex, scol)
                                  other.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
                                end
                                Integer(rowindex+1).upto(rowindex+y-1) do |srow|
                                  Integer(colindex+1).upto(colindex+x-1) do |scol|
                                    other = table.GetCell(srow, scol)
                                    other.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
                                  end
                                end
                                
                                cell.SetName(cellnode.attributes.getnameditem('Name').text)
                                cell.SetAttribute(0x40, cellnode.attributes.getnameditem('ReadOnly').text == "true")
                                cell.SetStyle(@stylemanager.find(cellnode.attributes.getnameditem('StyleID').text.to_i))
                                flags = cellnode.attributes.getnameditem('Flags').text.to_i
                                flags = flags << 16
                                #flags = flags & 0xFFFF0000
                                cell.SetAttribute(flags, true)
                            end
                        elsif rowcolnode.basename == "Parameters"
                            parameterlist = rowcolnode.childnodes
                            1.upto(parameterlist.length) do |k|                                                
                               param = parameterlist.item(k-1)
                               next if param.nodeName == "#text"
                               #key = param.childnodes.item(0).text
                               #value = param.childnodes.item(1).text
                               #table.SetProperty(key, value)
                               key = ''
                               value = ''
                               keyvaluelist = param.childnodes
                               1.upto(keyvaluelist.length) do |l|
                                keynode = keyvaluelist.item(l-1)
                                next if keynode.nodeName == "#text"
                                key = EncodeUtil.change("UTF-8", "GB2312", keynode.text) if keynode.nodeName == "Key"
                                value = EncodeUtil.change("UTF-8", "GB2312", keynode.text) if keynode.nodeName == "Value"
                                table.SetProperty(key, value)
                               end
                             end
                        end
                    end
                elsif topnode.basename == "Scripts"
                    scriptsnode = topnode
                    @script.setCalcSequence(scriptsnode.attributes.getnameditem('CalcSequence').text)
                    scriptlistnode = scriptsnode.childnodes
                    Integer(0).upto(scriptlistnode.length-1) do |i|
                       scriptnode = scriptlistnode.item(i)
                       next if scriptnode.nodeName == "#text"
                       tableid = scriptnode.attributes.getnameditem('TableID').text
                       scripttype = scriptnode.attributes.getnameditem('Type').text
                       if scripttype == '0' #表内计算
                           @script.setCalcScript(tableid, EncodeUtil.change("UTF-8", "GB2312", scriptnode.text))
                       elsif scripttype == '1' #表内审核
                           @script.setAuditScript(tableid, EncodeUtil.change("UTF-8", "GB2312", scriptnode.text))
                       elsif scripttype == '2'
                           @script.setCalcScript("", EncodeUtil.change("UTF-8", "GB2312", scriptnode.text))
                       elsif scripttype == '3'
                           @script.setAuditScript("", EncodeUtil.change("UTF-8", "GB2312", scriptnode.text))
                       elsif scripttype == '4'
                           @script.setCommonScript(EncodeUtil.change("UTF-8", "GB2312", scriptnode.text))
                       end
                    end
                elsif topnode.basename == "Dictionary"
                    dictnode = topnode
                    dict = @dictionFactory.CreateDiction()
                    dict.ID = dictnode.attributes.getnameditem('ID').text
                    dict.OnlyLeaf = dictnode.attributes.getnameditem('IsLeaf').text == "1"
                    dict.Length = dictnode.attributes.getnameditem('Length').text.to_i
                    dict.Levels = dictnode.attributes.getnameditem('Levels').text
                    dict.Name = EncodeUtil.change("UTF-8", "GB2312", dictnode.attributes.getnameditem('Name').text)
                    @dictionFactory.AddDiction(dict)
                    itemnodelist = dictnode.childnodes
                    Integer(0).upto(itemnodelist.length-1) do |i|
                       itemnode = itemnodelist.item(i)
                       next if itemnode.nodeName == "#text"
                       key = itemnode.attributes.getnameditem('Code').text
                       value = EncodeUtil.change("UTF-8", "GB2312", itemnode.attributes.getnameditem('Mean').text)
                       dict.AddDictItem(key, value)
                    end
                end
            end
        end
        
        
        def Ruby_ReadFromXML(doc)
            @parameters = Hash.new
            @tables = Array.new
            @dictionFactory = DictionFactory.new
            @script = CTaskScript.new
            
            doc.root.each_element('Parameters/Parameter') { |parameter_node|
                key = ""
                value = ""
                parameter_node.each_element('Key'){ |key_node|
                    key = key_node.text
                }
                parameter_node.each_element('Value'){ |value_node|
                    value = value_node.text
                }
                @parameters[key] = value
            }
            
            doc.root.each_element('Styles'){ |styles_node|
                @stylemanager = StyleManager.new  
                styles_node.each_element('Style'){ |stylenode|
                    style = @stylemanager.NewStyle()
                       style.m_clrBackColor = stylenode.attributes['BackColor'].delete('#').hex
                       style.m_nDataType = stylenode.attributes['DataType'].hex
                       style.m_nDecimalDigits = stylenode.attributes['DecimalDigits'].hex
                       style.m_clrForeColor = stylenode.attributes['ForeColor'].delete('#').hex
                       style.m_nID = stylenode.attributes['ID'].to_i
                       style.m_nInputType = stylenode.attributes['InputType'].hex
                       style.m_bWidthCheck = stylenode.attributes['IsCheckWidth']=="1"
                       style.m_bHideFormula = stylenode.attributes['IsHideFormula']=="1"
                       style.m_bThousandMark = stylenode.attributes['IsThousandMark']=="1"
                       style.m_bShowZero = stylenode.attributes['ShowZero']=="1"
                       style.m_nTextLength = stylenode.attributes['TextWidth'].to_i
                       
                       stylenode.each_element('Alignment') { |alignode|
                         style.m_nHoriAlign = alignode.attributes['HoriAlign'].to_i
                         style.m_nVertAlign = alignode.attributes['VertAlign'].to_i
                         style.m_bWrapText = alignode.attributes['WrapText'] == "1"
                         style.m_bShrinkToFit = alignode.attributes['ShrinkToFit'] == "1"
                       }
                       
                       stylenode.each_element('Borders/Border') { |bordernode|
                         pos = bordernode.attributes['Position'].to_i
                         style.m_Borders[pos].bDisplay = bordernode.attributes['Display'] == "true"
                         style.m_Borders[pos].LineColor = bordernode.attributes['LineColor'].delete("#").hex
                         style.m_Borders[pos].LineStyle = bordernode.attributes['LineStyle'].to_i
                         style.m_Borders[pos].LineWidth = bordernode.attributes['LineWidth'].to_i
                       }
                           
                       stylenode.each_element('Font'){ |fontnode|
                            style.m_Font.Size = fontnode.attributes['Size'].to_i
                            style.m_Font.FontName = fontnode.attributes['FontName']  #EncodeUtil.change("UTF-8", "GB2312", fontnode.attributes['FontName'])
                            style.m_Font.Bold = fontnode.attributes['Bold']=="1"
                            style.m_Font.CharSet = fontnode.attributes['CharSet']
                            style.m_Font.Underline = fontnode.attributes['Underline']=="1"
                            style.m_Font.StrikeThrough = fontnode.attributes['StrikeThrough']=="1"
                            style.m_Font.Italic = fontnode.attributes['Italic']=="1"    
                       }
                }
            }
            
            doc.root.each_element('Table') { |tablenode|
                id = tablenode.attributes['TableID']
                name = tablenode.attributes['TableName']   
                rowcount = tablenode.attributes['RowCount'].to_i
                colcount = tablenode.attributes['ColCount'].to_i
                table = CTable.new(@stylemanager, id, name)
                table.OnNewTable(rowcount, colcount, 0, 0)
                @tables<<table
                
                tablenode.each_element('Col') { |colnode|
                    empty = colnode.attributes['Empty'] == "1"
                    hidden = colnode.attributes['Hidden'] != "0"
                    width = colnode.attributes['Width'].to_i
                    colindex = colnode.attributes['Index'].to_i
                    table.SetEmptyCol(colindex) if empty
                    table.SetColHidden(colindex, hidden) 
                    table.SetColWidth(colindex, width)
                }
                
                tablenode.each_element('Row'){ |rownode|
                    empty = rownode.attributes['Empty'] == "1"
                    hidden = rownode.attributes['Hidden'] != "0"
                    height = rownode.attributes['Height'].to_i
                    rowindex = rownode.attributes['Index'].to_i
                    table.SetEmptyRow(rowindex) if empty
                    table.SetRowHidden(rowindex, hidden)
                    table.SetRowHeight(rowindex, height)
                    
                    rownode.each_element('Cell'){ |cellnode|
                        colindex = cellnode.attributes['Index'].to_i
                        cell = table.GetCell(rowindex, colindex)
                        cellnode.each_element('Data'){ |datanode|
                            cell.SetText(EncodeUtil.change('GB2312', 'UTF-8', datanode.text))
                        }
                        #cell.SetDescription(EncodeUtil.change("UTF-8", "GB2312", cellnode.attributes['Description']))
                        cell.SetDescription(cellnode.attributes['Description'])
                        cell.SetDictName(cellnode.attributes['DictName'])
                        cell.SetAttribute(CCell::TC_CF_STORE, cellnode.attributes['IsStoreDB'] == "1")
                        cell.SetAttribute(CCell::TC_CF_SUM, cellnode.attributes['IsSum'] == "1")
                        cell.SetAttribute(CCell::TC_CF_PRECISION, cellnode.attributes['IsConvertPrecision'] == "1")
                        x = cellnode.attributes['MergeAcross'].to_i
                        y = cellnode.attributes['MergeDown'].to_i
                        sz = CSize.new(x,y)
                        cell.SetCoveredScale(sz)
                        
                        #设置其他单元格无效
                        Integer(rowindex+1).upto(rowindex+y-1) do |srow|
                          other = table.GetCell(srow, colindex)
                          other.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
                        end
                        Integer(colindex+1).upto(colindex+x-1) do |scol|
                          other = table.GetCell(rowindex, scol)
                          other.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
                        end
                        Integer(rowindex+1).upto(rowindex+y-1) do |srow|
                          Integer(colindex+1).upto(colindex+x-1) do |scol|
                            other = table.GetCell(srow, scol)
                            other.SetAttribute(CCell::TC_CF_EFFECTIVE, false)
                          end
                        end
                        
                        cell.SetName(cellnode.attributes['Name'])
                        cell.SetAttribute(0x40, cellnode.attributes['ReadOnly'] == "true")
                        cell.SetStyle(@stylemanager.find(cellnode.attributes['StyleID'].to_i))
                        flags = cellnode.attributes['Flags'].to_i
                        flags = flags << 16
                        #flags = flags & 0xFFFF0000
                        cell.SetAttribute(flags, true)
                    }
                    
                    rownode.each_element('Parameters/Parameter') {|parameter_node|
                        key = ""
                        value = ""
                        parameter_node.each_element('Key'){ |key_node|
                            key = key_node.text
                        }
                        parameter_node.each_element('Value'){ |value_node|
                            value = value_node.text
                        }
                        if key == 'IsFloatTemplateRow'
                            table.SetFloatTemplateRow(rowindex, value=="true")
                        end
                    }
                }
                
                tablenode.each_element('Parameters/Parameter') { |parameter_node|
                    key = ""
                    value = ""
                    parameter_node.each_element('Key'){ |key_node|
                        key = key_node.text
                    }
                    parameter_node.each_element('Value'){ |value_node|
                        value = value_node.text
                    }
                    table.SetProperty(key, value)
                }
            
            }
            doc.root.each_element('Scripts'){ |scriptsnode|
                @script.setCalcSequence(scriptsnode.attributes['CalcSequence'])
                scriptsnode.each_element('Script') { |scriptnode|
                    tableid = scriptnode.attributes['TableID']
                    scripttype = scriptnode.attributes['Type']
                    if scripttype == '0' #表内计算xt
                        @script.setCalcScript(tableid, scriptnode.text||"")
                    elsif scripttype == '1' #表内审核
                        @script.setAuditScript(tableid, scriptnode.text||"")
                    elsif scripttype == '2'
                        @script.setCalcScript("",  scriptnode.text||"")
                    elsif scripttype == '3'
                        @script.setAuditScript("", scriptnode.text||"")
                    elsif scripttype == '4'
                        @script.setCommonScript( scriptnode.text||"")
                    end
                }
            }
            doc.root.each_element('Dictionary') { |dictnode|
                dict = @dictionFactory.CreateDiction()
                dict.ID = dictnode.attributes['ID']
                dict.OnlyLeaf = dictnode.attributes['IsLeaf'] == "1"
                dict.Length = dictnode.attributes['Length'].to_i
                dict.Levels = dictnode.attributes['Levels']
                dict.Name = dictnode.attributes['Name']
                @dictionFactory.AddDiction(dict)
                dictnode.each_element('Item') {|itemnode|
                    key = itemnode.attributes['Code']
                    value = itemnode.attributes['Mean']
                    dict.AddDictItem(key, value)
                }
            }
        end
        
        def AddAnEditHTMLCell2(table,row, col, dicFactory, readonly=false, record=nil, float=false, currency=nil)
            next if table.IsColHidden(col)
            cell = table.GetCell(row, col)
            result = ""
            if !cell.IsEffective() || cell.GetStyle().GetID()<0
                return ""
            end
            
            if !cell.IsStore()
                cellattr = "clsCellNoStore"
            else
                cellattr = "clsCellStore"
            end
            msz = cell.GetCoveredScale()
            
            if msz.x > 1
                colspanstring = "colspan='#{msz.x}'"
            else
                colspanstring = ""
            end            

            if msz.y > 1
                rowspanstring = "rowspan='#{msz.y}'"
            else
                rowspanstring = ""
            end
            
            align="left"
            if cell.GetHoriAlign() == CellStyle::DT_RIGHT
                align = "right"
            elsif cell.GetHoriAlign() == CellStyle::DT_CENTER
                align = "center"
            end
            height = table.GetRowHeight(row)
            1.upto(msz.y-1) do |i|
              height += table.GetRowHeight(row+1)
            end            
            rowheight = cs(height)
            
            width = table.GetColWidth(col)
            1.upto(msz.x-1) do |i|
              width += table.GetColWidth(col + i)
            end
            colwidth = cs(width)
            
            outcol = col+1
            while outcol < table.GetColumnCount() && (!table.GetCell(row, outcol).IsEffective() || table.GetCell(row, outcol).GetStyle().GetID()<1)
                colwidth += cs(table.GetColWidth(outcol))
                outcol += 1
            end
            
            fieldId = "#{table.GetTableID().downcase}_#{table.GetCellLabel(row, col)}"
            fieldName = "#{table.GetTableID().downcase}[#{table.GetCellLabel(row, col)}]"
            
            if !cell.IsStore() || table.IsEmptyRow(row) || table.IsEmptyCol(col)
                result << "\t\t\t\t<td align='#{align}' #{colspanstring} #{rowspanstring} class = 'style#{cell.GetStyle().GetID()}' style='background: buttonface;'>#{cell.GetText().gsub(" ", "&nbsp;")}</td>\n"
            else
                backcolor = '#%06X' % cell.GetStyle().GetBackColor()
                backcolor = '#FFFF66' if cell.IsReadOnly() || float
                
                if cell.GetInputType() == CCell::ItComboBox
                    dictID = cell.GetDictName()
                    #print "dictid:#{dictID}\n"
                    dict = dicFactory.GetDictionByID(dictID.to_s)
                    if dict
                        result << "\t\t\t\t<td align='left' #{colspanstring} #{rowspanstring} class = 'style#{cell.GetStyle().GetID()}' expression='#{table.GetTableID()}.#{table.GetCellDBFieldName(row, col)}' #{"style='background-color=#{backcolor}'" if cell.IsReadOnly()|| float} #{"readonly='true'" if cell.IsReadOnly} celltype='tree' tree=dict_#{dict.ID}>\n"
                        if !readonly 
                            result << "<select #{'disabled="disabled"' if cell.IsReadOnly()} name='#{fieldName}' id='#{fieldId}' style='BORDER-BOTTOM: solid 1px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px; width:100%; height:100%; background-color:#{backcolor}'>\n"
                            result << "<option value=''></option>"
                            if dict
                                items = dict.GetAllItems()
                                items.each{|key, value|
                                   value = EncodeUtil.change("GB2312", "UTF-8", value)
                                   select = ''
                                   select = 'selected' if record && key.to_s == EncodeUtil.change('GB2312', 'UTF-8', record[table.GetCellDBFieldName(row, col)].to_s)
                                   result << "\t\t\t\t\t<option value='#{key}' #{select}>#{value}</option>\n"
                                }
                            end
                            result << "\t\t\t\t</select>\n"
                        else        #显示对应的含义
                            if record
                                value = EncodeUtil.change("GB2312", "UTF-8", record["#{table.GetCellDBFieldName(row, col)}"].to_s)
                                if dict.GetItemName(value).to_s.size > 0
                                  result << EncodeUtil.change("GB2312", "UTF-8", dict.GetItemName(value))  #外部传入了记录
                                else
                                  result << value;
                                end
                            else
                                result << EncodeUtil.change("GB2312", "UTF-8", dict.GetItemName(cell.GetText()))
                            end
                        end
                    end
                    
                    result << "</td>\n"
                    
                elsif cell.GetInputType() == CCell::ItDate && !readonly
                    if record && record.send("#{table.GetCellDBFieldName(row, col)}")
                    	result << "\t\t\t\t<td align='left' #{colspanstring} #{rowspanstring} class='style#{cell.GetStyle().GetID()}' expression='#{table.GetTableID()}.#{table.GetCellDBFieldName(row, col)}' #{'style=background-color='+backcolor if cell.IsReadOnly() || float}><input readonly onchange='calc()' value='#{record.send("#{table.GetCellDBFieldName(row, col)}").strftime("%Y-%m-%d")}' #{'onclick="getDateString(this,oCalendarChs)"' if !cell.IsReadOnly()} type=text name='#{fieldName}' id='#{fieldId}' style='BORDER-BOTTOM: solid 1px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px; width:#{colwidth-1}mm; height:#{rowheight-1}mm; background-color:#{backcolor}'></input></td>\n"
                    else
                    	result << "\t\t\t\t<td align='left' #{colspanstring} #{rowspanstring} class='style#{cell.GetStyle().GetID()}' expression='#{table.GetTableID()}.#{table.GetCellDBFieldName(row, col)}' #{'style=background-color='+backcolor if cell.IsReadOnly() || float}><input readonly onchange='calc()' #{'onclick="getDateString(this,oCalendarChs)"' if !cell.IsReadOnly()} type=text name='#{fieldName}' id='#{fieldId}' style='BORDER-BOTTOM: solid 1px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px; width:#{colwidth-1}mm; height:#{rowheight-1}mm; background-color:#{backcolor}'></input></td>\n"
                    end
                else 
                    typetext = "input"
                    typetext = "textarea" if rowheight > 7    
                    celltype = ''
                    if cell.GetInputType() == CCell::ItDate
                      celltype = "celltype='date'"
                    elsif cell.GetInputType() == CCell::ItComboBox
                      celltype = "celltype='tree'"
                    elsif cell.GetDataType() == CCell::CtText
                      celltype = "celltype='text'"
                    end
                    
                    result << "\t\t\t\t<td align='left'  #{colspanstring} #{rowspanstring}  #{"valign=top" if rowheight>7} class='style#{cell.GetStyle().GetID()}' expression='#{table.GetTableID()}.#{table.GetCellDBFieldName(row, col)}' #{"style='background-color=#{backcolor}'" if cell.IsReadOnly() || float} #{"readonly='true'" if cell.IsReadOnly()} #{celltype}> "
                    if !readonly    #可编辑
                        #result <<"<#{typetext} type=text  #{'readonly' if cell.IsReadOnly} name='#{fieldName}' id='#{fieldId}' #{"rows="+(rowheight/4).to_s if rowheight>7} style='width:100%; height:90%; BORDER-BOTTOM: solid 1px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px; background-color:#{backcolor}'></#{typetext}>"
                        if record
                        	result <<"<#{typetext} type=text value='#{EncodeUtil.change('GB2312', 'UTF-8', record.send("#{table.GetCellDBFieldName(row, col)}").to_s)}'  #{'readonly' if cell.IsReadOnly} name='#{fieldName}' id='#{fieldId}' style='BORDER-BOTTOM: solid 1px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px; width:#{colwidth-1}mm; height:#{rowheight-1}mm; background-color:#{backcolor}'></#{typetext}>"
                        else
                        	result <<"<#{typetext} type=text onchange='calc()'  #{'readonly' if cell.IsReadOnly} name='#{fieldName}' id='#{fieldId}' style='BORDER-BOTTOM: solid 1px; BORDER-LEFT: dashed 0px; BORDER-RIGHT: dashed 0px; BORDER-TOP: dashed 0px; width:#{colwidth-1}mm; height:#{rowheight-1}mm; background-color:#{backcolor}'></#{typetext}>"
                        end
                    else            #只读
                        #考虑精度
                        cell_text = cell.GetText()
                        cell_text = EncodeUtil.change("GB2312", "UTF-8", record["#{table.GetCellDBFieldName(row, col)}"].to_s) if record
                        cell_text = record["#{table.GetCellDBFieldName(row, col)}"].strftime("%Y-%m-%d") if record && record["#{table.GetCellDBFieldName(row, col)}"].kind_of?(Time)
                        if cell.GetDataType() == CCell::CtNumeric && cell_text.strip.size != 0
                          begin
                             if currency && cell.IsConvert()
                                begin
                                  cell_text = "%.#{cell.GetDecimal()}f" % ((cell_text.to_f()*@parameters['currency.base'].to_f)/currency.to_f ).to_s
                                rescue                                
                                end
                             end
                             cell_text = "%.#{cell.GetDecimal()}f" % cell_text
                             cell_text = format_thousand(cell_text) if cell.IsThousand
                             
#                            cell_text = "%.#{cell.GetDecimal()}f" % cell_text
#                            if currency && cell.IsConvert()
#                              begin
#                                cell_text = "%.#{cell.GetDecimal()}f" % ((cell_text.to_f()*@parameters['currency.base'].to_f)/currency.to_f ).to_s
#                                cell_text = format_thousand(cell_text)
#                              rescue
#                              end
#                            else
#                              cell_text = format_thousand(cell_text)
#                            end
                            
                          rescue
                            cell_text = ""
                          end
                        end
                        
                        result << cell_text
                    end
                    result << "</td>\n"
                    
                end                
            end
            
            result
        end
        
        #table: CTable
        #row: 整形
        #dicFactory: DictionFactory
        #readonly: bool类型
        #record : ActiveRecord::Base
        #float_detail : 浮动明细行，bool类型
        def AddAnEditHTMLRow(table, row, dicFactory, readonly, record=nil, float_detail=false, currency=nil, floatindex=nil)
            result = ""
            
            floattag = ""
            floattag = "floattpl=#{table.PhyRowToLogicRow(row+1)} floatindex=#{floatindex} " if float_detail
            #YtLog.info floattag if float_detail
            result << "\t\t\t<tr class='xsltTr' #{floattag} style='height:#{cs(table.GetRowHeight(row))}mm'>\n"
                begincol = 0
                while table.IsColHidden(begincol)
                    begincol += 1
                end
                Integer(begincol).upto(table.GetColumnCount()-1) do |col|
                    next if table.IsColHidden(col)
                    cell = table.GetCell(row, col)
                    next if !cell.IsEffective() || cell.GetStyle().GetID() < 0
                    
                    result << AddAnEditHTMLCell2(table, row, col, dicFactory, readonly, record, table.IsFloatTemplRow(row) && !float_detail, currency)
                end
            result << "\t\t\t</tr>\n"
            result
        end
         
        #changesize
        def cs(size) 
            size = size*256 / (72*5*10)
        end
        
        def format_thousand(num)
	     num_text = num.to_s
	     dot_index = num_text.index('.')||num_text.length
	     dot_index -= 3
	     while dot_index >0 && num_text[dot_index-1, 1] != "-"
		    num_text = num_text[0, dot_index] + "," + num_text[dot_index, num_text.to_s.size()-dot_index]
		    dot_index -= 3
	     end
	     num_text
        end
end
