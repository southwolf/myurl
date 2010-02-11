require "ScriptEngine"

class SumController < ApplicationController
  layout "main"
  #在汇总页面点击了 "**汇总" 按钮
  def sum_result
    p params
    tasktimeid = params[:taskTimeID]
    unitid = params[:unitID]
    flag = params[:flag]    #0：选中节点，1：选中节点和直接下级节点，2：选中节点和全部下级节点
    if params[:operation] == "sumNode"                  #封存
      meta = $TaskDesc[session[:task].strid]
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
      
      
      children_ids = []
      children = UnitFMTableData.find(unitid).children rescue nil
      
      #如果是汇总集团差额表，则转换成汇总其父单位
      unit = UnitFMTableData.find(unitid) rescue nil
      if unit and unit.BBLX=='1'
        YtLog.info "集团差额单位汇总, 集团单位代码：#{unit.p_parent}"
        children = UnitFMTableData.find(unit.p_parent).children rescue nil
      end
      
      if children
        for child in children
          children_ids << child['unitid']
        end
      end
      sum_node(tasktimeid, unitid, children_ids)
      redirect_to :action => 'index'
    elsif params[:operation] == "unenvelopsubmitdata"   #解封
      unenvelop_submit_data(tasktimeid, unitid, flag)
    elsif params[:operation] == "validateNodeSum"       #节点检查
      check_node(params[:unitID].split(','), tasktimeid)
    elsif params[:operation] == "adjustNodeDiff"        #调整差额表
      adjust_node_diff(params[:unitID].split(','), tasktimeid)
    end
  end
  
  def select_sum_dialog
    @tasktimeid = params[:id]
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
    UnitFMTableData.reset_column_information
    @select_units = UnitFMTableData.find(:all, :conditions => "unitid like '%H'")
    render :action =>'select_sum_dialog', :layout=>false
  end
  
  def add_select_sum_node_dialog
    render :action => 'add_select_sum_node_dialog', :layout => false
  end
  
  def add_select_sum_node
    unitid = params[:code] + "H"
    unitname = params[:unitName]
    
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
    UnitFMTableData.reset_column_information() 
    @unit = UnitFMTableData.new()
    @unit['unitid'] = unitid
    @unit["#{meta.unitname}"] = unitname
    @unit["p_parent"] = ""
    @unit["#{meta.reporttype}"] = unitid[9,9]
    @unit.save
    
    render :action=>"add_select_node_ok", :layout => false
  end
  
  #进行选择汇总
  def select_sum
    @unitID = params[:unitID]
    unitids = params[:unitIDs].split(',')  
    @tasktimeid = params[:taskTimeID].to_i  
    
    #sum(session[:task].strid, @tasktimeid, @unitID, unitids)
    sum_node(@tasktimeid, @unitID, unitids)
    begin
      YtaplDraft.delete_all("unitid='#{@unitID}' and taskid=#{session[:task].id} and tasktimeid=#{@tasktimeid}")
    rescue
    end

    render :action=>'select_sum_ok', :layout => false
  end

private
  def sum_node(tasktimeid, unitid, direct_children)
    tasktimeid = params[:taskTimeID].to_i || session[:tasktime]
    records = _GetUnitData(session[:task].strid, unitid, tasktimeid, true, true)
    
    meta = $TaskDesc[session[:task].strid]
    #标志。第几张汇总表对应的表模型
    sumhash = Hash.new
    sum_table_array = Array.new
    index = 0
    
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
    UnitFMTableData.reset_column_information() 
    unit = UnitFMTableData.find(unitid) rescue nil
    
    for table in meta.helper.tables
      if table.GetProperty('SumTable') == "1"
        sumhash[index] = table
        sum_table_array << table
        index += 1
      end
    end
         
    #固定表先清零
    Integer(0).upto(records.size()-1) do |i|
      record = records[i]
      conn = ActiveRecord::Base.connection
      columns = conn.columns("ytapl_#{session[:task].strid}_#{sum_table_array[i].GetTableID()}".downcase)
      columns_hash = Hash.new
      for column in columns
        columns_hash[column.name] = column
      end
        
      record.attributes().each{|key, value|
        #判断是否是数字型单元格
        next if key == "unitid" || key == "tasktimeid" || key=="display"
        record[key] = 0 if columns_hash[key].type == :float || columns_hash[key].type == :float
        record[key] = '' if columns_hash[key].type == :string
      }
    end              
      
     UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
     for child in direct_children        
        #只取汇总表的数据，空表不取
       YtLog.info child, "sum child unit"
       child_records = _GetUnitData(session[:task].strid, child, tasktimeid, true, true)
       Integer(0).upto(records.length-1) do |i|        
         #逐个字段相加
         records[i].attributes().each{|key, value|
           #YtLog.info "#{key} #{records[i][key]} #{child_records[i][key]}"
           #判断是否是数字型单元格
           records[i][key] = records[i][key].to_f + child_records[i][key] if records[i][key].kind_of?(Numeric) && child_records[i][key].kind_of?(Numeric) && key != "tasktimeid"
         }          
       end
     end
     
     #保存固定表记录 
     Integer(0).upto(records.size()-1) do |i|
         UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{sumhash[i].GetTableID()}".downcase)
         UnitTableData.reset_column_information
         records[i].save
     end
     
     YtLog.info "sum float tables"
     #汇总浮动表
     for table in sum_table_array
       sum_float_table(table, tasktimeid, unitid, direct_children)   
     end    
     
     
     
#     #如果任务是 中材会计，而且汇总单位是差额单位，则删除掉所有其他表的数据，除了DXFL浮动表
#     if session[:task].strid=='cwkj' and unit.BBLX=='1'   
#        YtLog.info '中材会计报表测试，集团差额单位汇总，删除所有非汇总表数据'     
#        for table in meta.helper.tables
#          if table.GetTableID() != meta.helper.tables[0].GetTableID() and table.GetTableID()!='DXFL'
#              #p "ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase
#              UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase) 
#              UnitTableData.reset_column_information
#              UnitTableData.delete_all("unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
#               
#          
#              Integer(0).upto(table.GetRowCount()) do |row|
#                if table.IsFloatTemplRow(row)
#                  logicRow = table.PhyRowToLogicRow(row+1)
#                  table_name = "ytapl_#{session[:task].strid}_#{table.GetTableID()}_#{logicRow}".downcase
#                  #p table_name
#                  UnitTableData.set_table_name("#{table_name}".downcase) 
#                  UnitTableData.reset_column_information
#                  UnitTableData.delete_all("unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
#                end
#              end
#          end
#        end
#        
#     #如果任务是 中材会计，而且汇总单位是集团单位，则删除掉DXFL浮动表
#     else
#        YtLog.info '中材会计报表测试，集团单位汇总，删除所有差额单位汇总表的数据'     
#        for table in meta.helper.tables
#          if table.GetTableID()=='DXFL'
#              UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase) 
#              UnitTableData.reset_column_information
#              UnitTableData.delete_all("unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
#               
#          
#              Integer(0).upto(table.GetRowCount()) do |row|
#                if table.IsFloatTemplRow(row)
#                  logicRow = table.PhyRowToLogicRow(row+1)
#                  table_name = "ytapl_#{session[:task].strid}_#{table.GetTableID()}_#{logicRow}".downcase
#                  #p table_name
#                  UnitTableData.set_table_name("#{table_name}".downcase) 
#                  UnitTableData.reset_column_information
#                  UnitTableData.delete_all("unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
#                end
#              end
#          end
#        end
#                
#     end
      
      
       
     
     #汇总完毕后运算,运算完毕审核，审核完毕自动保存
     #判断是否有活动脚本
     if (session[:task].activescriptsuitname.to_s != "")
       scripts = Ytscript.find(:all, :conditions=>"taskid = #{session[:task].taskid}  and name = '#{session[:task].activescriptsuitname}'")
       if scripts.size > 0
         scriptstr = scripts[0].content    #获得xml文本串
         script = CTaskScript.new          #生成CTaskScript对象
         script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
         wholerecords = _GetUnitData(session[:task].strid, unitid, tasktimeid, true) #没填的数据不取
         scriptengine = TaskScriptEngine.new(session[:task].strid, script, unitid, Yttasktime.find(tasktimeid).begintime, meta.helper.tables, wholerecords, false)
         scriptengine.Prepare
         scriptengine.ExecuteAllCalc()
         scriptengine.ExecuteAllAudit()
         errors = scriptengine.GetErrors()
         if errors.size > 0
           flash[:error] = "汇总数据审核出现错误"
           YtaplDraft.delete_all("unitid='#{unitid}' and taskid=#{session[:task].id} and tasktimeid=#{tasktimeid}")
           return
         end
       end
     end

     
     #封存子单位数据和汇总单位数据
     for child in direct_children
       #添加提交记录
       begin
         p [child, session[:task].strid, tasktimeid]
         fillstate = Ytfillstate.find [child, session[:task].strid, tasktimeid]
       rescue Exception=>err
         p err
         fillstate = nil
       end
       if !fillstate  #未填报但封存
         fillstate = Ytfillstate.new
         fillstate.unitid = child
         fillstate.taskid = session[:task].strid
         fillstate.tasktimeid = tasktimeid
         fillstate.flag = 3
         fillstate.filldate = Time.new
       else
         fillstate.flag = 5 if fillstate.flag!=3
       end        
       fillstate.save
     end if params[:envlopflag] == "true" || !params[:envlopflag]
     
     #添加提交记录
     begin
         fillstate = Ytfillstate.find [unitid, session[:task].strid, tasktimeid]
     rescue
         fillstate = Ytfillstate.new
         fillstate.unitid = unitid
         fillstate.taskid = session[:task].strid
         fillstate.tasktimeid = tasktimeid
     end       
     fillstate.filldate = Time.new
     fillstate.flag = 5
     fillstate.save if params[:envlopflag] == "true" || !params[:envlopflag]
     
     begin
           YtaplDraft.delete_all("unitid='#{unitID}' and taskid=#{session[:task].id} and tasktimeid=#{tasktimeid}")
     rescue
     end
         
     flash[:notice] = "节点汇总完毕"
  end
  
  #汇总浮动表
  #table : CTable实例
  #tasktimeid : 任务时间id
  #unitid : 单位id
  #children : 直接子单位id数组
  def sum_float_table(table, tasktimeid, unitid, children)
    Integer(0).upto(table.GetRowCount()) do |row|
      if table.IsFloatTemplRow(row)
        logicRow = table.PhyRowToLogicRow(row+1)
        
        table_name = "ytapl_#{session[:task].strid}_#{table.GetTableID()}_#{logicRow}".downcase
        YtLog.info table_name
        UnitTableData.set_table_name(table_name)
        UnitTableData.reset_column_information
        #清空
        UnitTableData.delete_all("unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")        
        
        quote_ids = []
        for child in children
          quote_ids << "'" + child + "'"
        end
        
        names = UnitTableData.column_names
        names.delete('unitid')
        names.delete('tasktimeid')
        names.delete('float_id')
        sql = "insert into #{table_name}(unitid, tasktimeid, #{names.join(',')})
              (select '#{unitid}', #{tasktimeid}, #{names.join(',')} from #{table_name}
              where tasktimeid = #{tasktimeid} and unitid in (#{quote_ids.join(',')}) 
              order by unitid, float_id asc)"
        conn = ActiveRecord::Base.connection
        conn.execute(sql)
      end
    end
  end
  
  #汇总
  #tasktimeid:任务时间id
  #sumunit:被汇总出来的单位，字符串
  #subunits:参与汇总的单位，数组，元素为字符串
#  def sum(taskstrid, tasktimeid, unitid, subunits)
#    records = _GetUnitData(session[:task].strid, unitid, tasktimeid, true, true)
#      
#    meta = $TaskDesc[session[:task].strid]
#    
#    #标志。第几张汇总表对应的表模型
#    sumhash = Hash.new
#    sum_table_array = Array.new
#    index = 0
#    for table in meta.helper.tables
#        if table.GetProperty('SumTable') == "1"
#          sumhash[index] = table
#          sum_table_array << table
#          index += 1
#        end
#    end
    
    #先清零
#    Integer(0).upto(records.size()-1) do |i|
      #for record in records
#      record = records[i]
#      conn = ActiveRecord::Base.connection
#      columns = conn.columns("ytapl_#{session[:task].strid}_#{sum_table_array[i].GetTableID()}".downcase)
#      columns_hash = Hash.new
#      for column in columns
#        columns_hash[column.name] = column
#      end
#      record.attributes().each{|key, value|
        #判断是否是数字型单元格
        #record[key] = 0 if (record[key].kind_of?(Numeric)||record[key].kind_of?(NilClass)) && key != "unitid" && key != "tasktimeid"
#        next if key == "unitid" || key == "tasktimeid" || key=="display"
#        record[key] = 0 if columns_hash[key].type == :float || columns_hash[key].type == :float
#        record[key] = '' if columns_hash[key].type == :string
#      }
#    end      
    
    #UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
    #direct_children = UnitFMTableData.find(:all, :conditions => "p_parent = #{unitid}")
#    for unit in subunits
#      child_records = _GetUnitData(session[:task].strid, unit, tasktimeid, true, true)
#      Integer(0).upto(records.length-1) do |i|          
#        #逐个字段相加
#        records[i].attributes().each{|key, value|
          #判断是否是数字型单元格
#          if records[i][key].kind_of?(Numeric) &&child_records[i][key].kind_of?(Numeric) && key != "tasktimeid" && !child_records[i][key].kind_of?(NilClass)
#            records[i][key] = records[i][key].to_s.to_f + child_records[i][key] 
#          end
#        }          
#      end
#    end
    
#    Integer(0).upto(records.size()-1) do |i|
#      UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{sumhash[i].GetTableID()}".downcase)
#      records[i].save
#    end
    
    #汇总完毕后运算,运算完毕自动保存
    #判断是否有活动脚本
#    if (session[:task].activescriptsuitname.to_s != "")
#      scripts = Ytscript.find(:all, :conditions=>"taskid = #{session[:task].taskid}  and name = '#{session[:task].activescriptsuitname}'")
#      if scripts.size > 0
#        scriptstr = scripts[0].content    #获得xml文本串
#        script = CTaskScript.new          #生成CTaskScript对象
#        script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
#        YtLog.info records
        
#        wholerecords = _GetUnitData(session[:task].strid, unitid, tasktimeid, false) #没填的数据不取
#        scriptengine = TaskScriptEngine.new(session[:task].strid, script, unitid, tasktimeid, meta.helper.tables, wholerecords, true)
#        scriptengine.Prepare
#        scriptengine.ExecuteAllCalc()        
        
#        scriptengine = TaskScriptEngine.new(session[:task].strid, script, unitid, Yttasktime.find(tasktimeid).begintime, meta.helper.tables, wholerecords, true)
#        scriptengine.Prepare
#        scriptengine.ExecuteAllCalc()
          
#        scriptengine.ExecuteAllAudit()
#        errors = scriptengine.GetErrors()
#        if errors.size > 0
#            flash[:error] = "汇总数据审核出现错误"
#            YtaplDraft.delete_all("unitid='#{unitid}' and taskid=#{session[:task].id} and tasktimeid=#{tasktimeid}")
#            return
#        end
#      end
#    end

    #封存子单位数据和汇总单位数据
#    for child in subunits
      #添加提交记录
#      begin
#        fillstate = Ytfillstate.find [child, session[:task].strid, tasktimeid]
#      rescue
#        fillstate = nil
#      end
#      if !fillstate  #未填报但封存
#        fillstate = Ytfillstate.new
#        fillstate.unitid = child
#        fillstate.taskid = session[:task].strid
#        fillstate.tasktimeid = tasktimeid
#        fillstate.flag = 3
#        fillstate.filldate = Time.new  
#      else
#        fillstate.flag = 5 if fillstate!=3
#      end       
      
#      fillstate.save
#    end   
      
    #添加提交记录
#    begin
#        fillstate = Ytfillstate.find [unitid, session[:task].strid, tasktimeid]
#    rescue
#        fillstate = Ytfillstate.new
#        fillstate.unitid = unitid
#        fillstate.taskid = session[:task].strid
#        fillstate.tasktimeid = tasktimeid
#    end       
#    fillstate.filldate = Time.new  
#    fillstate.flag = 5
#    fillstate.save
#  end
  
  #解封
  def unenvelop_submit_data(tasktimeid, unitid, flag)
    units = GetUnits(session[:task].strid, unitid.split(','), flag)
    for unit in units
      if unit.p_parent && unit.p_parent.size > 0
      	p_states = Ytfillstate.find(:all, :conditions=>"taskid = '#{session[:task].strid}' and unitid = '#{unit.p_parent}' and tasktimeid = #{tasktimeid}")
      	if p_states.size > 0  && p_states[0].flag == 5
        	flash[:error] = "父节点处于封存状态，子节点不允许解封"    
        	redirect_to :action => 'index'
        	return
      	end
      end
      states = Ytfillstate.find(:all, :conditions=>"taskid = '#{session[:task].strid}' and unitid = '#{unit.unitid}' and tasktimeid = #{tasktimeid}")
      next if states.length == 0
      states[0].flag = 4
      states[0].save
    end
    
    flash[:notice] = "数据启封完毕"    
    redirect_to :action => 'index'
  end
  
  #节点检查
  #unitIDs : 单位id数组，元素为字符串
  #tasktimeid : 任务时间id，整形
  def check_node(unitIDs, tasktimeid)
    meta = $TaskDesc[session[:task].strid]
    @result = Array.new
    
    for unitid in unitIDs
      #获得表记录，非汇总表不取
      records = _GetUnitData(session[:task].strid, unitid, tasktimeid, false, true)
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
      unit_record = UnitFMTableData.find(unitid)
      
      #获得子单位记录集
      children_records = Array.new
      for unit_child in unit_record.children
        arr = _GetUnitData(session[:task].strid, unit_child.unitid, tasktimeid, false, true)
        children_records << arr if arr.size > 0
      end
      
      #比较父单位与子单位数据
      error_count = 0
      Integer(0).upto(records.size()-1) do |i| 
        finish = false
        records[i].attributes.each{ |key, value|          
          next if key.downcase == "unitid" || key.downcase=="tasktimeid" || key.downcase=="display"
          next if value.kind_of?(String)
          temp = 0
          Integer(0).upto(children_records.size()-1) do |j|
            temp += children_records[j][i][key].to_s.to_f
          end
          if (temp - value.to_s.to_f).abs>0.0001
            result_node = Array.new
            result_node[0] = key                              #单位id
            result_node[1] = unit_record["#{meta.unitname}"]  #单位名称
            count = 0
            for table in meta.helper.tables
              if count == i && table.GetProperty('SumTable') == "1"
                result_node[2] = table.GetTableID()          #表id
                result_node[3] = table.GetTableName()        #表名称
              end
              count += 1 if table.GetProperty('SumTable') == "1"
            end
            result_node[4] = key                              #指标
            result_node[5] = value                            #父单位值
            result_node[6] = temp                             #子单位值
            @result << result_node
            error_count += 1
            finish=true
            break if error_count == 10
          end
        }
        break if finish
      end
    end
    
    flash[:notice] = "节点检查完毕"
    render :action=>"check_node"
  end

  #调节差额表
  def adjust_node_diff(unitIDs, tasktimeid)
    meta = $TaskDesc[session[:task].strid]
    
    #标志。第几张汇总表对应的表模型
    sumhash = Hash.new
    index = 0
    for table in meta.helper.tables
        if table.GetProperty('SumTable') == "1"
          sumhash[index] = table
          index += 1
        end
    end
    
    for unitid in unitIDs
      YtLog.info unitid, '集团'
      parent_records = _GetUnitData(session[:task].strid, unitid, tasktimeid, false, true)
      
      #获得子单位记录集
      diff_records = Array.new
      children_records = Array.new
      
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
      unit_record = UnitFMTableData.find(unitid)
      for unit_child in unit_record.children
        YtLog.info unit_child.unitid
        if unit_child["#{meta.reporttype}"].to_s == '1'
          diff_records = _GetUnitData(session[:task].strid, unit_child.unitid, tasktimeid, true, true)
          YtLog.info diff_records
        else
          arr = _GetUnitData(session[:task].strid, unit_child.unitid, tasktimeid, false, true)
          children_records << arr if arr.size > 0
        end        
      end
      
      #开始计算
      Integer(0).upto(parent_records.size()-1) do |i|        #遍历表
        parent_records[i].attributes.each{ |key, value|      
          next if !parent_records[i][key].kind_of?(Numeric)
          next if key == "tasktimeid" 
          next if parent_records[i][key].kind_of?(NilClass)
          diff_records[i][key] = value
          for child in children_records
            next if child[i][key].kind_of?(NilClass)
            diff_records[i][key] -= child[i][key]
          end
        }
        
        Integer(0).upto(diff_records.size()-1) do |i|
          UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{sumhash[i].GetTableID()}".downcase)
          diff_records[i].save
        end
        
        diff_records[i].save
      end
    end
    
    flash[:notice] = "差额表调整完毕"    
    redirect_to :action => 'index'
  end
end
