require("chartdirector")

class ScalarqueryController < ApplicationController
  include ChartDirector::InteractiveChartSupport

  layout "main"
  def index  
    meta = $TaskDesc[session[:task].strid]
    helper = meta.helper
    @ytables = helper.tables
    
    @tablesarray = Array.new    
    for table in helper.tables      
      @tables = Hash.new
      @tables[table.GetTableName()]= helper.TableToEditHTML(table, helper.dictionFactory,{:readonly=>true, :encoding=>"utf-8", :only_table_tag=>true})
      @tablesarray << @tables
    end
    
    @tasktimes = Yttasktime.find(:all, :conditions=>"taskid = #{session[:task].id}", :order=>"tasktimeid")
    render :action=>'index'
  end
  
  def query
    #任务时间数组,字符串型
    @tasktimeids = params[:taskTimes].split(',')
    
    #指标数组,字符串型,如FM.DWMC, ZBB.A1
    @scalars = params[:expressions].split(',')
    
    @meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid.downcase}_#{@meta.fmtable.downcase}")
    
    @tasktimes = Yttasktime.find(:all, :conditions=>"tasktimeid in (#{params[:taskTimes]})", :order=>"tasktimeid")
    
    #获得指标的中文名称
    @scalar_desc = Array.new
    for scalar in @scalars
      t = scalar.split(".")
      for table in @meta.helper.tables
        if table.GetTableID() == t[0]
          rowcol = table.GetCellByFieldName(t[1])
          if rowcol[0] == -1
            @scalar_desc << scalar
          else
            cell = table.GetCell(rowcol[0], rowcol[1])
            if cell.GetDescription.length == 0
              @scalar_desc << scalar
            else
              @scalar_desc << cell.GetDescription
            end
          end
        end
      end
    end    
    
    #查询
    fieldstr = "1 "
    for scalar in @scalars
      fieldstr +="," + scalar + " as " + scalar.sub(".", "_")
      scalar = scalar.sub(".", "_")
    end
    
    Integer(0).upto(@scalars.size-1) do |i|
      @scalars[i] = @scalars[i].sub(".", "_")
    end
    
    tablestr = ""
    for table in @meta.helper.tables
      if tablestr == ""
        tablestr += "ytapl_#{session[:task].strid.downcase}_#{table.GetTableID().downcase} as #{table.GetTableID} "
      else
        tablestr += ", ytapl_#{session[:task].strid.downcase}_#{table.GetTableID().downcase} as #{table.GetTableID} "
      end
    end
    
    unit_condition_str = ""    
    Integer(1).upto(@meta.helper.tables.size-1) do |i|
      unit_condition_str += "#{@meta.helper.tables[i].GetTableID()}.unitid = #{@meta.helper.tables[0].GetTableID()}.unitid and "
    end
    if params[:unitIDs] && params[:unitIDs].size > 1
      unit_condition_str += " #{@meta.helper.tables[0].GetTableID()}.unitid in (#{params[:unitIDs]}) " 
    else
      unit_condition_str += "1=1"
    end
    tasktime_condition_str = ""
    Integer(2).upto(@meta.helper.tables.size-1) do |i|
      tasktime_condition_str += " and #{@meta.helper.tables[i].GetTableID()}.tasktimeid = #{@meta.helper.tables[1].GetTableID()}.tasktimeid "
    end
    tasktime_condition_str += "and #{@meta.helper.tables[1].GetTableID()}.tasktimeid in (#{params[:taskTimes]})"
                           
    #代码字典条件                       
    diction_condition_str = ""
    diction_conditions = params[:dictions].split("-")
    for diction_condition in diction_conditions
      next if diction_condition.size < 1
      YtLog.info diction_condition
      diction_condition_str += " and (1=2 "
      single_conditions = diction_condition.split(",")
      for single_condition in single_conditions
        next if single_condition.size < 1
        YtLog.info single_condition
        diction_condition_str += " or " + single_condition
      end
      diction_condition_str += ")"
    end
    
    if params[:unitIDs] && params[:unitIDs].size > 1
      @units = UnitFMTableData.find_by_sql("select * from ytapl_#{session[:task].strid.downcase}_#{@meta.helper.tables[0].GetTableID().downcase} as #{@meta.helper.tables[0].GetTableID()} where unitid in (#{params[:unitIDs]}) #{diction_condition_str} order by unitid")
    else
      @units = UnitFMTableData.find_by_sql("select * from ytapl_#{session[:task].strid.downcase}_#{@meta.helper.tables[0].GetTableID().downcase} as #{@meta.helper.tables[0].GetTableID()} where 1=1 #{diction_condition_str} order by unitid")
    end
    #单位id数组,字符串型
    @unitids = Array.new
    for unit in @units
      @unitids << unit.unitid
    end
                                    
    @result = UnitTableData.find_by_sql("select #{fieldstr},
                              #{@meta.helper.tables[0].GetTableID()}.unitid,
                              #{@meta.helper.tables[1].GetTableID()}.tasktimeid
                              from #{tablestr}
                              where #{unit_condition_str} #{tasktime_condition_str} #{diction_condition_str}
                              order by #{@meta.helper.tables[0].GetTableID()}.unitid,
                                    #{@meta.helper.tables[1].GetTableID()}.tasktimeid")
    
    @order_result = Hash.new
    for unit in @unitids
      unit = unit.sub("'", "")
      unit = unit.sub("'", "")
      @order_result[unit.to_s] = Hash.new
    end
    
    for result in @result
      @order_result[result["unitid"].to_s][result["tasktimeid"].to_s] = result
    end
    
    if params[:toexcel] == "1"
      send_file result_to_excel, :filename=>"result.xls"
    else
      render :layout=>"application"
    end
  end
  
  def chart
    @datas = params[:datas].split(",", -1)
    @unitids = params[:unitids]
    @tasktimeids = params[:tasktimeids].split(",")
    render :layout=>"application"
  end
  
  def getchart    
    @title = params[:title]
    params[:datas] = "" if !params[:datas]
    @datas = params[:datas].split(",", -1)
    if !@datas || @datas.size == 0
      @datas = Array.new
      @datas<< "" 
    end
    Integer(0).upto(@datas.size-1) do |index|
      @datas[index] = @datas[index].to_f
    end
    @labels = params[:labels].split(",", -1)
    
    if params[:charttype].to_s == "pie"
      chart_pie(@title, @datas, @labels)
      #chart_else
    elsif params[:charttype].to_s == "bar"
      chart_bar(@title, @datas, @labels)
    elsif params[:charttype].to_s == "line"
      chart_line(@title, @datas, @labels)
    elsif params[:charttype].to_s == "trend"
      chart_trend(@title, @datas, @labels)
    elsif params[:charttype].to_s == "area"
      chart_area(@title, @datas, @labels)
    elsif params[:charttype].to_s == "polar"
      chart_polar(@title, @datas, @labels)
    else
      chart_pie(@title, @datas, @labels)
    end

  end

  def chart_pie(title, data, labels, getmap=false)
        c = ChartDirector::PieChart.new(600, 250)      
        c.setDefaultFonts("SIMSUN.TTC","SIMSUN.TTC");
        c.setPieSize(300, 110, 90)
        c.addTitle2(ChartDirector::Bottom, title)
        c.setLabelStyle("SIMSUN.TTC", 9)
        c.set3D()
        c.setData(data, labels)
        c.setExplode(0)
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline", :layout=>false)
  end
  
  def chart_bar(title, data, labels)
        c = ChartDirector::XYChart.new(600, 250)               
        c.setDefaultFonts("SIMSUN.TTC", "SIMSUN.TTC");
        c.addTitle2(ChartDirector::Bottom, title)
        c.setPlotArea(30, 15, 580, 190)
        c.addBarLayer(data)
        c.xAxis().setLabels(labels)
        c.xAxis().setLabelStyle("SIMSUN.TTC", 9)
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline", :layout=>false)
  end
  
  def chart_line(title, data, labels)
        c = ChartDirector::XYChart.new(600, 250)     
        c.setDefaultFonts("SIMSUN.TTC","SIMSUN.TTC");
        c.addTitle2(ChartDirector::Bottom, title)
        c.setPlotArea(30, 15, 480, 160)
        c.addLineLayer(data)
        c.xAxis().setLabels(labels)
        c.xAxis().setLabelStyle("SIMSUN.TTC", 9)
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline", :layout=>false)
  end
  
  def chart_trend(title, data, labels)
        c = ChartDirector::XYChart.new(600, 250)     
        c.setDefaultFonts("SIMSUN.TTC","SIMSUN.TTC");
        c.setPlotArea(30, 15, 480, 160, 0xffffff, -1, -1, 0xc0c0c0, -1)

        c.addLegend(140, 16, false, "", 8).setBackground(ChartDirector::Transparent)
        c.addTitle2(ChartDirector::Bottom, title)
        c.xAxis().setLabels(labels)
        c.xAxis().setLabelStyle("SIMSUN.TTC", 9)
        
        lineLayer = c.addLineLayer()     
        dataset = lineLayer.addDataSet(data, 0xcc9966, "")
        dataset.setDataLabelStyle("SIMSUN.TTC", 9)
        dataset.setDataSymbol(ChartDirector::SquareSymbol, 7)
        c.addTrendLayer(data, 0x008000, "").setLineWidth(2)
        
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline", :layout=>false)
  end
  
  def chart_area(title, data, labels)
        c = ChartDirector::XYChart.new(600, 250)     
        c.setDefaultFonts("SIMSUN.TTC","SIMSUN.TTC");
        c.addTitle2(ChartDirector::Bottom, title)
        c.setPlotArea(30, 15, 480, 160)
        c.addAreaLayer(data)
        c.xAxis().setLabels(labels)
        c.xAxis().setLabelStyle("SIMSUN.TTC", 9)
        
        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline", :layout=>false)

    
  end
  
  def chart_polar(title, data, labels)
        c = ChartDirector::PolarChart.new(600, 250)     
        c.setDefaultFonts("SIMSUN.TTC","SIMSUN.TTC");
        c.addTitle2(ChartDirector::Bottom, title)
        c.setPlotArea(300, 130, 90)
        c.addAreaLayer(data, 0x9999ff)
        c.angularAxis().setLabels(labels)

        send_data(c.makeChart2(ChartDirector::PNG), :type => "image/png",
            :disposition => "inline",:layout=>false)
  end

private
  def result_to_excel
    #require "spreadsheet/excel"
    #include Spreadsheet
    result_file = "tmp/scalar_result.xls"
    workbook = Excel.new(result_file)
    worksheet = workbook.add_worksheet(EncodeUtil.change("GB2312", "UTF-8", "查询结果"))
    format0=workbook.add_format(:color => "black",:bold => 0,:bg_color => "silver", :align=>"left")
    #format0.top = format0.bottom = format0.left = format0.right = 1
    format1=workbook.add_format(:color => "black",:bold => 0,:bg_color => "silver", :align=>"merge")
    #format1.top = format1.bottom = format1.left = format1.right = 1
    format2=workbook.add_format(:color => "black",:bold => 0, :text_wrap=>true)
    format2.num_format = "0.00"  
    #format2.top = format2.bottom = format2.left = format2.right = 1
    format2.align="right"
    
    f_row = workbook.add_format(:color=>"black", :bold=>0, :italic=>false, :text_wrap=>true)
    worksheet.format_column(0, 30, f_row)
    
    #写入指标
    index = 1
    for scalar in @scalar_desc
      worksheet.write(0, 1+(index-1)*@tasktimes.size, EncodeUtil.change("GB2312", "UTF-8", scalar), format1)
      worksheet.format_column(1+(index-1)*@tasktimes.size, 25, f_row)
      1.upto(@tasktimes.size-1) do |i|
        worksheet.write(0, 1+(index-1)*@tasktimes.size+i, nil, format1)
        worksheet.format_column(1+(index-1)*@tasktimes.size+i, 25, f_row)
      end
      
      if @tasktimes.size > 1
        1.upto(@tasktimes.size) do |i|
          worksheet.write(1, (index-1)*@tasktimes.size+i, EncodeUtil.change("GB2312", "UTF-8", @tasktimes[i-1].begintime.strftime("%Y年%m月")), format1)
        end      
      end
      
      index += 1
    end
    
    #写入单位数据
    if @tasktimes.size >1
      row_index = 2
    else
      row_index = 1
    end
    for unit in @units
      worksheet.write(row_index, 0, EncodeUtil.change("GB2312", "UTF-8", unit[@meta.unitname]), format0)
      unitdata = @order_result[unit[@meta.unitname]]
      time_index = 1
      for tasktime in @tasktimes
         record = @order_result[unit["unitid"]][tasktime.id.to_s]
         if !record
            col_index = 0
            for scalar in @scalars
              worksheet.write(row_index, col_index * @tasktimes.size + time_index, nil, format2)
              col_index += 1
            end 
            time_index += 1
            next
         end
         
         col_index = 0
         for scalar in @scalars
            YtLog.info scalar
           if !is_digit_str(record[scalar]) || scalar=="FM_QYDM"  #人民日报要查单位代码
            worksheet.write(row_index, col_index * @tasktimes.size + time_index, EncodeUtil.change("GB2312", "UTF-8", record[scalar]), format2)
           else
            worksheet.write(row_index, col_index * @tasktimes.size + time_index, record[scalar].to_f, format2)
           end
           col_index += 1
         end
         time_index += 1
      end      
      row_index += 1
    end
    workbook.close
    result_file
  end
  
  def is_digit_str(str)
    return true if !str
    Integer(0).upto(str.size-1) do |i|
      if (str[i]<'0'[0] || str[i]>'9'[0])&& str[i] != '.'[0] && str[i] != '-'[0]
        return false
      end
    end
    true
  end
end
