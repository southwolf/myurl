require "task"
require "rexml/document"
require "zlib"
require "base64"

class FrontServiceController < ApplicationController
  wsdl_service_name 'FrontService'
  web_service_scaffold :invoke
  
  #传入的data经过了zip压缩和base64编码
  def uploadData(data, username, password);
    #todo.. 在此判断用户是否有单位的写权限
    
    username = Base64.decode64(username)
    print "---------upload data------------------\n"
    stream = Base64.decode64(data)
    file = File.new('tmp/simple.zip', 'wb')
    file << stream
    file.close
    
    file = File.new('tmp/simple.zip', 'rb')
    gz = Zlib::GzipReader.new(file)
    stream = gz.read
    file.close    
    
    if $OS.downcase == "windows"
      result = upload_data_by_windows(stream, username)
    else
      rawstream = stream
      stream = stream.sub(/<\?xml version[\w\W]+\?>/, "")
      stream = EncodeUtil.change("UTF-8", "GB2312", stream)
      result.errCode = upload_data_by_unix(stream, rawstream, username)
    end    
    
    #审核不通过
    if result.errCode==2
      
    else
      result.content = "finished"
    end
    
    YtLog.info result.errCode
    YtLog.info result.content
    
    begin
      DataLog(INFO, "成功上报的数据,上报时间#{Time.new().strftime('%Y-%m-%d')}, 上报人#{username}")
    rescue
    end
    
    result
  end
  
  #传入的data没有经过压缩编码，直接是明文
  def uploadData2(data, username, password);
    #todo.. 在此判断用户是否有单位的写权限
    
    username = Base64.decode64(username)
    print "---------upload data2------------------\n"

    stream = data
    
    if $OS.downcase == "windows"
      result = upload_data_by_windows(stream, username)
    else
      rawstream = stream
      stream = stream.sub(/<\?xml version[\w\W]+\?>/, "")
      stream = EncodeUtil.change("UTF-8", "GB2312", stream)
      result.errCode = upload_data_by_unix(stream, rawstream, username)
    end    
    
    #审核不通过
    if result.errCode==2
      
    else
      result.content = "finished"
    end
    
    begin
      DataLog(INFO, "成功上报的数据,上报时间#{Time.new().strftime('%Y-%m-%d')}, 上报人#{username}")
    rescue
    end
    
    result
  end
  
  def upload_data_by_unix(stream, rawstream, username='')
    YtLog.info Time.new
    doc = Document.new(stream)
    YtLog.info Time.new    
    
    root = doc.root    
    #print "\nroot\n" + root.to_s
    YtLog.info root.attribute("ID"), "Task"
    
    tasks = Task.find(:all, :conditions => "strid = '#{root.attribute('ID')}'");
    if tasks.length == 0
      result.errCode = 1
      result.content = "task not found"
      return result
    else
      task = tasks[0]
    end
    
    meta = $TaskDesc[task.strid]
    
    root.elements.each("//taskTime") {|t|
      YtLog.info t.attributes["taskTime"]
      ta = t.attributes["taskTime"][0,10].split("-")
      tasktime = Time.mktime(ta[0].to_i, ta[1].to_i, ta[2].to_i, 0, 0, 0)
      yttasktimes = Yttasktime.find(:all, :conditions => "taskid = #{task.id} and begintime = '#{tasktime.strftime('%Y-%m-%d')}'")
      next if yttasktimes.length == 0
      yttasktime = yttasktimes[0]
      t.each_element('unit') {|unit|
        YtLog.info "unit:"+unit.attributes["ID"]
        unitID = unit.attributes["ID"]
        
        unit.each_element('flag'){|flag|
          #包含保存标志
          if flag.attributes['operation'] == 'save'
            begin
              draft = YtaplDraft.find [unitID, task.id, yttasktime.id]
            rescue
              draft = YtaplDraft.new
              draft.unitid = unitID
              draft.taskid = task.id
              draft.tasktimeid = yttasktime.id
            end
            draft.content = EncodeUtil.change("UTF-8", "GB2312", rawstream)
            draft.save  
            #返回
            DataLog(INFO, "成功保存数据,保存时间#{Time.new().strftime('%Y-%m-%d')}, 上报人#{username}")
            return 0
          end
        }
        
        
        unit.each_element('table'){|table|
          #print "\ntable:" + table.attributes["ID"]
          tablename = table.attributes["ID"]          
          if tablename == meta.helper.tables[0].GetTableID()    #封面表
            UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{tablename}".downcase) 
            UnitFMTableData.reset_column_information
            begin
              unitdata = UnitFMTableData.find(unitID)
            rescue
              unitdata = UnitFMTableData.new
              unitdata['unitid'] = unitID
              newly_created = true
            end
          else                                                  #非封面表
            UnitTableData.set_table_name("ytapl_#{task.strid}_#{tablename}".downcase) 
            UnitTableData.reset_column_information
            UnitTableData.delete_all("unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}")
            unitdata = UnitTableData.new
          end
          
          #print "\ntable--------#{table.attributes['ID']}"
          table.each_element('cell'){ |cell|
           # print "cell"
           # print "\n field : #{cell.attributes['field']}  ---   value : #{cell.attributes['value']}"
            if unitdata.attribute_names().include?(cell.attributes["field"])
              #判断是否日期型
              if unitdata.column_for_attribute(cell.attributes["field"]).type == :datetime
                unitdata[cell.attributes["field"]] = cell.attributes["value"] if cell.attributes["value"].size() > 0
              else
                unitdata[cell.attributes["field"]] = unitdata.column_for_attribute(cell.attributes["field"]).type_cast(cell.attributes["value"])  
              end
              
            end
          }
          unitdata["unitid"] = unitID
          unitdata["p_parent"] = unitdata["#{meta.parentunit}"] + '9' if newly_created && unitdata["#{meta.parentunit}"].to_s.length > 0
          unitdata["tasktimeid"] = yttasktime.id if tablename.downcase != meta.helper.tables[0].GetTableID().downcase
          unitdata.save
          
          #浮动表
          table.each_element('floatRow'){ |float_row|
            row_id = float_row.attributes["ID"]
            UnitTableData.set_table_name("ytapl_#{task.strid}_#{tablename}_#{row_id}".downcase) 
            UnitTableData.reset_column_information
            UnitTableData.delete_all("unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}")
            float_id = 1
            float_row.each_element('row'){ |row|
               print "floatrow #{float_id}\n"
               unitdata = UnitTableData.new
               unitdata["unitid"] = unitID
               unitdata["tasktimeid"] = yttasktime.id
            #   unitdata.float_id = float_id
               float_id += 1
               row.each_element('cell'){ |cell|
                  print "\n field : #{cell.attributes['field']}  ---   value : #{cell.attributes['value']}"
                  if unitdata.attribute_names().include?(cell.attributes["field"])
                    unitdata[cell.attributes["field"]] = unitdata.column_for_attribute(cell.attributes["field"]).type_cast(cell.attributes["value"])
                  end
                }
                unitdata.save
            }
          }
        } #table
        
        #添加提交记录
        begin
          fillstate = Ytfillstate.find [unitID, task.strid, yttasktime.id]
        rescue
          fillstate = Ytfillstate.new
          fillstate.unitid = unitID
          fillstate.taskid = task.strid
          fillstate.tasktimeid = yttasktime.id
        end
        
        fillstate.filldate = Time.new
        fillstate.flag = 4
        fillstate.save
        
        begin
            YtaplDraft.delete_all("unitid='#{unitID}' and taskid=#{task.id} and tasktimeid=#{yttasktime.id}")
        rescue
        end
      }   #unit
      
    }     #root
    
    0
  end
  
  def upload_data_by_windows(data,  username='')
    result = ServiceResult.new
    result.errCode = 0
    
    YtLog.info "begin windows upload at " + Time.new().to_s
    require 'win32ole'
    doc = WIN32OLE.new("Msxml2.DOMDocument.6.0")
    doc.loadXML(data)
    YtLog.info "load finished at " + Time.new().to_s
    
    root = doc.documentElement
    tasks = Task.find(:all, :conditions => "strid = '#{root.attributes.getnameditem('ID').text}'");
    if tasks.length == 0
      result.errCode = 1
      return result
    else
      task = tasks[0]
    end    
    
    meta = $TaskDesc[task.strid]
    
    tasktimenodes = root.childnodes
    Integer(0).upto(tasktimenodes.length-1) do |n1|
      tasktimenode = tasktimenodes.item(n1)
      ta = tasktimenode.attributes.getnameditem("taskTime").text[0,10].split("-")
      tasktime = Time.mktime(ta[0].to_i, ta[1].to_i, ta[2].to_i, 0, 0, 0)
      yttasktimes = Yttasktime.find(:all, :conditions => "taskid = #{task.id} and begintime = '#{tasktime.strftime('%Y-%m-%d')}'")
      next if yttasktimes.length == 0
      yttasktime = yttasktimes[0]
      
      unitnodes = tasktimenode.childnodes
      Integer(0).upto(unitnodes.length-1) do |n2|
        unitnode = unitnodes.item(n2)
        unitID = unitnode.attributes.getnameditem("ID").text
        
        YtLog.info "unit:"+unitnode.attributes.getnameditem("ID").text
        tablenodes = unitnode.childnodes
        Integer(0).upto(tablenodes.length-1) do |n3|
          tablenode = tablenodes.item(n3)
          if tablenode.basename == "flag" && tablenode.attributes.getnameditem("operation").text == 'save'
            begin
              draft = YtaplDraft.find [unitID, task.id, yttasktime.id]
            rescue
              draft = YtaplDraft.new
              draft.unitid = unitID
              draft.taskid = task.id
              draft.tasktimeid = yttasktime.id
            end
            draft.content = EncodeUtil.change("UTF-8", "GB2312", data)
            draft.save  
            #返回
            DataLog(INFO, "成功保存数据,保存时间#{Time.new().strftime('%Y-%m-%d')}, 上报人#{username}")
            result.errCode = 0
            return result
          elsif tablenode.basename == "table"          
            tablename = tablenode.attributes.getnameditem("ID").text
            if tablename == meta.helper.tables[0].GetTableID()    #封面表
              UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{tablename}".downcase) 
              UnitFMTableData.reset_column_information
              begin
                unitdata = UnitFMTableData.find(unitID)
              rescue
                unitdata = UnitFMTableData.new
                unitdata['unitid'] = unitID
                newly_created = true
              end
            else          
              UnitTableData.set_table_name("ytapl_#{task.strid}_#{tablename}".downcase) 
              UnitTableData.reset_column_information
              UnitTableData.delete_all("unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}")
              unitdata = UnitTableData.new                      
            end
          
            cellnodes = tablenode.childnodes
            Integer(0).upto(cellnodes.length-1) do |n4|
              cellnode = cellnodes.item(n4)
              next if cellnode.basename != "cell"
              field = cellnode.attributes.getnameditem("field").text
              next if field == "tasktimeid"
              field = 'p_parent' if field == "P_PARENT"
              if unitdata.attribute_names().include?(field)
              #判断是否日期型                
                value = EncodeUtil.change("UTF-8", "GB2312", cellnode.attributes.getnameditem("value").text)
                if unitdata.column_for_attribute(field).type == :datetime
                  unitdata[field] = value if value.to_s.size > 0
                else
                  unitdata[field] = unitdata.column_for_attribute(field).type_cast(value)  
                end
              end  
            end
            unitdata["unitid"] = unitID
            unitdata["p_parent"] = unitdata["#{meta.parentunit}"] + '9' if newly_created && unitdata["#{meta.parentunit}"].to_s.length > 0
            unitdata["tasktimeid"] = yttasktime.id if tablename.downcase != meta.helper.tables[0].GetTableID().downcase
            unitdata.save
            
            floatnodes = tablenode.childnodes
            Integer(0).upto(floatnodes.length-1) do |n4|
              floatnode = floatnodes.item(n4)
              next if floatnode.basename != "floatRow"
              row_id = floatnode.attributes.getnameditem("ID").text
              YtLog.info "floatrow id = " + row_id
              UnitTableData.set_table_name("ytapl_#{task.strid}_#{tablename}_#{row_id}".downcase) 
              UnitTableData.reset_column_information
              UnitTableData.delete_all("unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}")
              float_id = 1
              rownodes = floatnode.childnodes
              Integer(0).upto(rownodes.length-1) do |n5|
                rownode = rownodes.item(n5)
                floatdata = UnitTableData.new
                floatdata["unitid"] = unitID
                floatdata["tasktimeid"] = yttasktime.id
                #floatdata.float_id = float_id
                float_id += 1
                  floatcellnodes = rownode.childnodes
                  Integer(0).upto(floatcellnodes.length-1) do |n6|
                  floatcellnode = floatcellnodes.item(n6)
                      field = floatcellnode.attributes.getnameditem("field").text
                      value = EncodeUtil.change("UTF-8", "GB2312", floatcellnode.attributes.getnameditem("value").text)
                      print "\n field : #{field}  ---   value : #{value}"
                      
                      if floatdata.attribute_names().include?(field)
                        floatdata[field] = floatdata.column_for_attribute(field).type_cast(value)
                      end
                    end
                    floatdata.save
                  end
              end
              
            
          end    
        end      
        
        
        
#        #进行服务器段的审核
#        auditErrors = ""
#        auditScripts = ""
#        @unit_error_warn = Hash.new
#        #判断是否有活动脚本
#        if (task.activescriptsuitname.to_s != "")        
#          scripts = Ytscript.find(:all, :conditions=>"taskid = #{task.taskid} and name = '#{task.activescriptsuitname}'")
#          if scripts.size > 0
#            scriptstr = scripts[0].content    #获得xml文本串
#            script = CTaskScript.new          #生成CTaskScript对象
#            script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
#
#            tasktimeid = yttasktime.id
#            print "---------audit #{unitID}-------\n"
#            errors = Array.new
#            warns = Array.new
#            realunits = GetUnits(task.strid, unitID.split(','), 0)
#            records = _GetUnitData(task.strid, unitID, tasktimeid, false) #没填的数据不取
#            @unit_error_warn[unitID] = [nil, nil, realunits[0][meta.unitname]]
#            if records.size != 0
#              scriptengine = TaskScriptEngine.new(task.strid, script, unitID, yttasktime.begintime, meta.helper.tables, records)
#              scriptengine.Prepare
#              scriptengine.ExecuteAllAudit()
#              for error in scriptengine.GetErrors()
#                errors << error
#                auditErrors += error[0] + ";"
#                for cell in error[1]
#                  auditErrors += cell + ";"
#                end
#                auditErrors += "$"
#                
#                auditScripts = "a(1==0,'#{error[0]}'" 
#                #for cell in error[1]
#                  #auditScripts += "," + cell
#                #end
#                auditScripts += ") $\n"
#              end
#        
#              @unit_error_warn[unitID] = [errors, warns, records[0][meta.unitname]]
#              
#              #审核不通过时，删除所有上传的数据
#              if errors.size > 0
#                YtLog.info "上报数据审核不成功  ... "
#                YtLog.info "删除单位(#{unitID})上报的数据  ... "
#                
#                YtLog.info "unit:"+unitnode.attributes.getnameditem("ID").text
#                
#                tablenodes = unitnode.childnodes
#                Integer(0).upto(tablenodes.length-1) do |n3|
#                  tablenode = tablenodes.item(n3)
#                  
#                  if tablenode.basename == "table" 
#                    tablename = tablenode.attributes.getnameditem("ID").text
#                    if tablename != meta.helper.tables[0].GetTableID()
#                      UnitTableData.set_table_name("ytapl_#{task.strid}_#{tablename}".downcase) 
#                      UnitTableData.reset_column_information
#                      UnitTableData.delete_all("unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}")
#                      
#                      floatnodes = tablenode.childnodes
#                      Integer(0).upto(floatnodes.length-1) do |n4|
#                        floatnode = floatnodes.item(n4)
#                        next if floatnode.basename != "floatRow"
#                        row_id = floatnode.attributes.getnameditem("ID").text
#                        
#                        YtLog.info "ytapl_#{task.strid}_#{tablename}_#{row_id}".downcase
#                        YtLog.info "unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}"
#                        
#                        UnitTableData.set_table_name("ytapl_#{task.strid}_#{tablename}_#{row_id}".downcase) 
#                        UnitTableData.reset_column_information
#                        UnitTableData.delete_all("unitid = '#{unitID}' and tasktimeid = #{yttasktime.id}")
#                      end
#                    end
#                  end
#                end
#                
#                result.errCode = 2
#                result.content = auditScripts  #auditErrors
#                p auditScripts
#                return result
#              end
#              
#              YtLog.info "上报数据审核成功  ... "
#            end
#          end
#        end
        
        
        
        #添加提交记录
        begin
          fillstate = Ytfillstate.find [unitID, task.strid, yttasktime.id]
        rescue
          fillstate = Ytfillstate.new
          fillstate.unitid = unitID
          fillstate.taskid = task.strid
          fillstate.tasktimeid = yttasktime.id
        end
        fillstate.filldate = Time.new
        fillstate.flag = 4
        fillstate.save
        
        #去掉审核记录
        begin
          auditinfo = Ytauditinfo.find [unitID, task.strid, yttasktime.id]
        rescue
          auditinfo = Ytauditinfo.new
          auditinfo.unitid = unitID
          auditinfo.taskid = task.strid
          auditinfo.tasktimeid = yttasktime.id
        end
        auditinfo.auditdate = Time.new
        auditinfo.flag = 0
        auditinfo.auditor = ''
        auditinfo.save
        
        #删除保存的数据
        begin
          YtaplDraft.delete_all("unitid='#{unitID}' and taskid=#{task.id} and tasktimeid=#{yttasktime.id}")
        rescue
        end
  
      end
    end
   
    return result
  end
  
  def downloadData(taskID, unitID, date, username, password)
    #todo.. 在此判断用户是否有单位的读权限
    
    result = ServiceResult.new    
    taskID = taskID.unpack("m").to_s.downcase   #为了方便linux运行
    unitID = unitID.unpack("m").to_s
    username = username.unpack("m").to_s
    password = password.unpack("m").to_s
    print "---------------------------------------------------------"
    print "\nGetUnitData -- taskID #{taskID}, unitID#{unitID.to_s}, date #{date}, username: #{username}, password:#{password} \n"
    print "---------------------------------------------------------\n"
    doc = Document.new("<taskModel></taskModel>")
    doc.root.add_attributes({"ID" => taskID})
    tasktime = date 
    tasktimeid = 0
    
    tasks = Task.find(:all, :conditions=>"strid = '#{taskID}'")
    
    if tasks.length == 0
      result.errCode = 2
      result.content = 'no such task'
      return result
    else
      task = tasks[0]
    end
    
    tasktimes = Yttasktime.find(:all, :conditions => "begintime = '#{tasktime}' and taskid = #{task.id}")
    if tasktimes.length == 0
      result.errCode = 1
      result.content = "    no such tasktime"
      return result
    else
      tasktimeid = tasktimes[0].id
    end
    
    
    tasktimenode = doc.root.add_element(Element.new("taskTime"))
    tasktimenode.add_attributes({"taskTime" => tasktime.to_s + "T00:00:00+08:00"})
    
    #判断在draft表中是否有上次保存的数据
    begin
      draft = YtaplDraft.find [unitID, task.id, tasktimeid]
      f = open('tmp/simple2.zip', 'wb')
      gz = Zlib::GzipWriter.new(f)
      gz.write EncodeUtil.change("GB2312", "UTF-8", draft.content)
      gz.close
    
      file = File.new('tmp/simple2.zip', "rb")
      stream = file.read()
      stream = Base64.encode64(stream)
      file.close
      result.errCode = 0
      result.content = stream
      p stream
      return result
    rescue Exception=>err

    end
    
    meta = $TaskDesc[taskID]
    fmtable = meta.helper.tables[0]   #封面表
    UnitTableData.set_table_name("ytapl_#{taskID}_#{fmtable.GetTableID()}".downcase)
    units = Array.new
    if unitID ==""                    #所有单位
      units = UnitTableData.find(:all)
    else
      units = UnitTableData.find(:all, :conditions=>"unitid = '#{unitID}'")
    end

    for unit in units
      YtLog.info "unit : #{unit.unitid}"
      unitnode = tasktimenode.add_element(Element.new("unit"))
      unitnode.add_attributes({"ID" => unit.unitid})
      count = 0
      for table in meta.helper.tables       
        if count == 0 #封面表
          tablenode = unitnode.add_element(Element.new('table'))
          tablenode.add_attributes("ID" => table.GetTableID())
          UnitFMTableData.set_table_name("ytapl_#{taskID}_#{table.GetTableID()}".downcase)
          UnitFMTableData.reset_column_information
          tabledata = UnitFMTableData.find unit.unitid rescue nil
          next if !tabledata   
          for field in tabledata.attribute_names() 
            cellnode = tablenode.add_element(Element.new('cell'))
            cellnode.add_attributes({"field"=>field, "value"=>tabledata[field].to_s})
          end
        else  #不是封面表
          tablenode = unitnode.add_element(Element.new('table'))
          tablenode.add_attributes("ID" => table.GetTableID())
          UnitTableData.set_table_name("ytapl_#{taskID}_#{table.GetTableID()}".downcase)
          UnitTableData.reset_column_information
          tabledata = UnitTableData.find [unit.unitid ,tasktimeid] rescue nil
          next if !tabledata  
          for field in tabledata.attribute_names() 
            cellnode = tablenode.add_element(Element.new('cell'))
            cellnode.add_attributes({"field"=>field, "value"=>tabledata[field].to_s})
          end          
          
          #添加浮动表数据
          Integer(0).upto(table.GetRowCount()-1) do |row|
            next if !table.IsFloatTemplRow(row)
            float_node = tablenode.add_element(Element.new('floatRow'))
            float_id = table.PhyRowToLogicRow(row+1)
            float_node.add_attributes({"ID" => float_id})
            YtLog.info "ytapl_#{taskID}_#{table.GetTableID()}_#{float_id}   "
            UnitTableData.set_table_name("ytapl_#{taskID}_#{table.GetTableID()}_#{float_id}".downcase)
            floats = UnitTableData.find(:all, :conditions=>"unitid = '#{unit.unitid}' and tasktimeid = '#{tasktimeid}'")
            for float in floats
              row_node = float_node.add_element(Element.new('row'))
              for field in float.attribute_names() 
                cellnode = row_node.add_element(Element.new('cell'))
                cellnode.add_attributes({"field"=>field, "value"=>float[field].to_s})
              end
            end
          end
        end
        count+=1
      end
    end
 
    xmlstr = ''
    doc.write(Output.new(xmlstr, "GB2312"), -1)
    #p xmlstr
    
    f = open('simple.zip', 'wb')
    gz = Zlib::GzipWriter.new(f)
    gz.write xmlstr
    gz.close
    
    file = File.new('simple.zip', "rb")
    stream = file.read()
    stream = Base64.encode64(stream)
    file.close
    
    File.delete('simple.zip')
  
    result.errCode = 0
    result.content = stream
    result
  end
  
  def downloadAllData(taskID, date, username, password)
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def downloadDataByTree(taskID, unitID, date, username, password)
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def publishTask(definition, username, password)
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def downloadTask(id, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def deleteTask(taskID, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def publishDictionary(content, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def downloadDictionary(id, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def deleteDictionary(id, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def publishScriptSuit(taskID, script, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def downloadScriptSuit(taskID, suitName, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
  
  def deleteScriptSuit(taskID, suitName, username, password);
    result = ServiceResult.new
    result.errCode = 10
    result.content = "hello"
    
    result
  end
end
