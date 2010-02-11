require "rexml/document"

class Util
  
 class << self
  #获得直接子节点,返回ActionRecord数组
  def GetDirectChildren(taskstrid, unitid, includeself = true)
    meta = $TaskDesc[taskstrid]
    fmtable = meta.helper.tables[0]
    UnitFMTableData.set_table_name("ytapl_#{taskstrid}_#{fmtable.GetTableID()}")
    
    return UnitFMTableData.find(:all, :conditions => "p_parent = '#{unitid}' #{'or unitid = unitid' if includeself}")
  end
  
  def GetChildren(taskstrid, unitid, includeself = true)
    YtLog.info "GetChildren"
    YtLog.info Time.new
    meta = $TaskDesc[taskstrid]
    fmtable = meta.helper.tables[0]
    UnitFMTableData.set_table_name("ytapl_#{taskstrid}_#{fmtable.GetTableID()}")
    
    result = Array.new
    if includeself
      result<<UnitFMTableData.find(unitid) 
    else
      children = UnitFMTableData.find(:all, :conditions => "p_parent = '#{unitid}'")
      for child in children
        result << child
      end
    end
    
    i=0
    while i<result.length
      unit = result[i]
      unitid = unit.unitid
      #单户报表不考虑
      if unitid[unitid.size()-1].to_s == '0'
        i += 1
        next
      end
      children = UnitFMTableData.find(:all, :conditions => "p_parent = '#{unitid}'")
      for child in children
        result << child
      end
      i += 1
    end
    YtLog.info Time.new
    result
  end
  
  #导出单位数据，使用字符串
  def ExportUnitData(taskID, tasktimeid, unitID, recursive=true)
    file = File.new("tmp/#{unitID}.xml", "w")
    file << '<?xml version="1.0" encoding="gb2312" standalone="no"?>'
    units = GetChildren(taskID, unitID, recursive)
    file << "<taskModel ID='#{taskID}'>"
    
    #查找相应的任务
    tasks = Task.find(:all, :conditions=>"strid = '#{taskID}'")
    
    if tasks.length == 0
      return ''   #没找到相应任务
    else
      task = tasks[0]
    end
    
    #查找任务时间记录
    tasktime = Yttasktime.find(tasktimeid)
    return '' if !tasktime
    
    file << "<taskTime taskTime='#{tasktime.begintime.strftime("%Y-%m-%d") + "T00:00:00+08:00"}'>"
    meta = $TaskDesc[taskID]
    fmtable = meta.helper.tables[0]   #封面表
    UnitTableData.set_table_name("ytapl_#{taskID}_#{fmtable.GetTableID()}")   
    index = 0
    for unit in units
      index += 1
      YtLog.info "#{index} #{unit.unitid}"
      file << "<unit ID='#{unit.unitid}'>"
      count = 0
      for table in meta.helper.tables
        UnitTableData.set_table_name("ytapl_#{taskID}_#{table.GetTableID()}")
        file << "<table ID='#{table.GetTableID()}'>"
        if count == 0 #封面表          
          tabledatas = UnitTableData.find(:all, :conditions=>"unitid = '#{unit.unitid}'")
          if tabledatas.length == 0
            file << "</table>"
            next
          end
          tabledata = tabledatas[0]   
          for field in tabledata.attribute_names() 
             next if field.to_s == "unitid"
             if field.to_s == "p_parent"
              file << "<cell field='P_PARENT' value='#{tabledata[field].to_s}'/>"
             else
              file << "<cell field='#{field}' value='#{tabledata[field].to_s}'/>"
             end
          end          
        else  #不是封面表
          tabledatas = UnitTableData.find(:all, :conditions=>"unitid = '#{unit.unitid}' and tasktimeid = '#{tasktimeid}'")
          if tabledatas.length == 0
            file << "</table>"
            next
          end
          tabledata = tabledatas[0]   
          for field in tabledata.attribute_names() 
            file << "<cell field='#{field}' value='#{tabledata[field].to_s}'/>"
          end          
        end
        file << "</table>"
        count+=1
      end
      
      file << "</unit>"
    end   
    
    file << "</taskTime>"
    file << "</taskModel>"
    file.close
    "tmp/#{unitID}.xml"
  end
  
  #导出单位数据,使用xml库
  def ExportUnitData_byxml(taskID, tasktimeid, unitID, recursive=true)
    #获得所有单位
    units = GetChildren(taskID, unitID, recursive)

    doc = Document.new("<taskModel></taskModel>")
    doc.root.add_attributes({"ID" => taskID})
    
    #查找相应的任务
    tasks = Task.find(:all, :conditions=>"strid = '#{taskID}'")
    
    if tasks.length == 0
      return ''   #没找到相应任务
    else
      task = tasks[0]
    end
    
    #查找任务时间记录
    tasktime = Yttasktime.find(tasktimeid)
    return '' if !tasktime
    
    tasktimenode = doc.root.add_element(Element.new("taskTime"))
    tasktimenode.add_attributes({"taskTime" => tasktime.begintime.strftime("%Y-%m-%d") + "T00:00:00+08:00"})
    
    meta = $TaskDesc[taskID]
    fmtable = meta.helper.tables[0]   #封面表
    UnitTableData.set_table_name("ytapl_#{taskID}_#{fmtable.GetTableID()}")
    
    index = 0
    #垃圾回收周期
    route = 1
    for unit in units
      index += 1
      YtLog.info "#{index} #{unit.unitid}"
      unitnode = tasktimenode.add_element(Element.new("unit"))
      unitnode.add_attributes({"ID" => unit.unitid})
      count = 0
      for table in meta.helper.tables
        #print "\ntable:#{table.GetTableID()}\n"
        UnitTableData.set_table_name("ytapl_#{taskID}_#{table.GetTableID()}")
        if count == 0 #封面表
          tablenode = unitnode.add_element(Element.new('table'))
          tablenode.add_attributes("ID" => table.GetTableID())
          
          tabledatas = UnitTableData.find(:all, :conditions=>"unitid = '#{unit.unitid}'")
          next if tabledatas.length == 0
          tabledata = tabledatas[0]   
          for field in tabledata.attribute_names() 
            cellnode = tablenode.add_element(Element.new('cell'))
            if field == "QYMC"
              cellnode.add_attributes({"field"=>field, "value"=>tabledata[field].to_s})
            else
              cellnode.add_attributes({"field"=>field, "value"=>tabledata[field].to_s})
            end            
          end
        else  #不是封面表
          tablenode = unitnode.add_element(Element.new('table'))
          tablenode.add_attributes("ID" => table.GetTableID())
          tabledatas = UnitTableData.find(:all, :conditions=>"unitid = '#{unit.unitid}' and tasktimeid = '#{tasktimeid}'")
          next if tabledatas.length == 0
          tabledata = tabledatas[0]   
          for field in tabledata.attribute_names() 
            cellnode = tablenode.add_element(Element.new('cell'))
            cellnode.add_attributes({"field"=>field, "value"=>tabledata[field].to_s})
          end          
        end
        count+=1
      end
      
      #每遍历20家单位开始垃圾回收
      route += 1
      if route == 20
        route = 0
        YtLog.info "garbage collect"
        GC.start
      end
    end
 
    xmlstr = ''
    doc.write(Output.new(xmlstr, "GB2312"), -1)
    
    return xmlstr
  end
  
  
  #获得浮动表中的某页
  #tablename: 字符串型，浮动表名称，如ytapl_qykb_kb1
  #float_id:  整形，浮动行逻辑行号
  #page : 整形，获得第几页
  #records_per_page: 每页击行
  def GetFloatPage(taskstrid, tableid, float_id, unitid, tasktimeid, page=1, records_per_page=$FLOAT_RECORDS_PER_PAGE)
    UnitTableData.set_table_name("ytapl_#{taskstrid}_#{tableid}_#{float_id}".downcase)
    return nil if page<1
    result = UnitTableData.find(:all, :conditions=>"unitid='#{unitid}' and tasktimeid='#{tasktimeid}'", :offset=>(page-1)*records_per_page, :order=>"float_id", :limit=>records_per_page)
    result
  end
  
  #获得浮动表的总页数
  def GetFloatPageCount(taskstrid, tableid, float_id, unitid, tasktimeid, records_per_page=$FLOAT_RECORDS_PER_PAGE)
    UnitTableData.set_table_name("ytapl_#{taskstrid}_#{tableid}_#{float_id}".downcase)
    total_count = UnitTableData.count("unitid='#{unitid}' and tasktimeid = #{tasktimeid}")
    odd = total_count % records_per_page
    odd = 1 if odd > 0
    return total_count / records_per_page + odd
  end
  
  
  #获得浮动表中的某页
  #tablename: 字符串型，浮动表名称，如ytapl_qykb_kb1
  #float_id:  整形，浮动行逻辑行号
  #page : 整形，获得第几页
  #records_per_page: 每页击行
  def GetFloatData(taskstrid, tableid, float_id, unitid, tasktimeid, page=1, records_per_page=$FLOAT_RECORDS_PER_PAGE)
    UnitFloatTableData.set_table_name("ytapl_#{taskstrid}_#{tableid}_#{float_id}".downcase)
    return nil if page<1
    result = UnitFloatTableData.find(:all, :conditions=>"unitid='#{unitid}' and tasktimeid='#{tasktimeid}'", :offset=>(page-1)*records_per_page, :order=>"float_id", :limit=>records_per_page)
    result
  end
  
  
 end 
end