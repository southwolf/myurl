module TransferHelper
  $DetailRow = 0
  #显示上报明细情况, otype -- all:所有情况;notfill:未填报;filled:已填报;query:查询
  #code:otype='query'时有用，包含的字符串，左包含
  def TransferDetail(taskstrid, tasktimeid, otype, code)
    result = ""
    meta = $TaskDesc[taskstrid]
    UnitFMTableData.set_table_name("ytapl_#{taskstrid}_#{meta.helper.tables[0].GetTableID()}")
    UnitFMTableData.reset_column_information
    
    #获得根节点
    #roots = UnitFMTableData.find(:all, :conditions => "p_parent ='' or p_parent is null")
    roots = GetUnitForest(session[:task].id, session[:user].id)
    index = 0
    for root in roots
      if includes?(taskstrid, tasktimeid, root.unitid, otype, code)
        result += OutputUnitDetail(taskstrid,root, tasktimeid, meta.unitname, meta.reporttype, otype, code, "table_#{index}")
        index += 1
      end
    end
    
    result
  end
  
  def OutputUnitDetail(taskstrid, unit, tasktimeid, name_field, report_type_field, otype, code, id='table', offset=0)
    result = ""
  
    whites = ""
    offset.times do
      whites += "&nbsp;&nbsp;"
    end
    
    if $DetailRow % 2 == 1
	   c = "TrLight"
	else
	   c="TrDark"
	end
	
	$DetailRow += 1
	
	filldate = ""
	#判断是否填了数
	state = Ytfillstate.find [unit.unitid, session[:task].strid, tasktimeid]
	if !state
	 filledStr = "<span class='style2'>否</span><span class='style2'>(启封)</span>"
	else
	 filledStr = "<span class='style1'>是</span>"
	 #state = states[0]
	 filldate = state.filldate.strftime("%Y-%m-%d %H:%M:%S")
	 if state.flag == 4
	   filledStr += "<span class='style2'>(启封)</span>"
	 else
	   filledStr += "<span class='style1'>(封存)</span>"
	 end
	end
	
	#判断是否审核了
	auditinfo = Ytauditinfo.find [unit.unitid, session[:task].strid, tasktimeid]
	#auditinfo = auditinfos[0] if auditinfos.length > 0
	if auditinfo
	   auditstr = "<span class='style1'>是#{('未过') if auditinfo.flag==0}</span>"
	else
	   auditstr = "<span class='style2'>否</span>" if !auditinfo
	end
	auditor = ""
	auditor = auditinfo.auditor if auditinfo
	auditdate = ""
	auditdate = auditinfo.auditdate.strftime("%Y-%m-%d %H:%M:%S") if auditinfo
	       
	#bgcolor='#FFFFFF'   可把单元格背景置为白色       
	       
    result += "<tr id='#{id}' class = '#{c}' onmouseover=\"this.style.backgroundColor ='#c4c9e1'\"  onmouseout=\"this.style.color='';this.style.backgroundColor =''\" >
      <td >#{whites}<a href='#' onclick=\"treetable_toggleRow('#{id}');\"><img src='/img/icon_#{unit["#{report_type_field}"]}.gif' class='button' alt='' width='16' height='16'/>#{unit.unitid}</a></td>
      <td><a href=\"javascript:showData(#{tasktimeid}, '#{unit.unitid}')\">#{unit["#{name_field}"]}</a></td>
      <td>#{filledStr}</td>
      <td>#{filldate}</td>
      <td>#{auditstr}</td>
      <td>#{auditdate}</td>
      <td>#{auditor}</td>
    </tr>"
    
    children = UnitFMTableData.find(:all, :conditions => "p_parent ='#{unit.unitid}'")
    index = 0
    for child in children
      if includes?(taskstrid, tasktimeid, child.unitid, otype, code)
        result += OutputUnitDetail(taskstrid, child, tasktimeid, name_field, report_type_field, otype, code, id + "_#{index}", offset+2)
        index += 1
      end
    end
    
    result
  end

  def includes?(taskstrid, tasktimeid, unitid, otype, code)
    return true if otype == "all"   #上报情况
    meta = $TaskDesc[taskstrid]
    begin
      UnitFMTableData.set_table_name("ytapl_#{taskstrid}_#{meta.fmtable}")
      unit_record = UnitFMTableData.find(unitid)
    rescue
      return false
    end
    if otype == "notfill"           #未上报
      states = Ytfillstate.find(:all, :conditions => "unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
      return true if states.length == 0
      for child in unit_record.children
        return true if includes?(taskstrid, tasktimeid, child.unitid, otype, code)
      end
      return false
    elsif otype == "filled"         #已上报
      states = Ytfillstate.find(:all, :conditions => "unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
      return true if states.length > 0
      for child in unit_record.children
        return true if includes?(taskstrid, tasktimeid, child.unitid, otype, code)
      end
      return false
    elsif otype == "query"          #查询
      return true if unitid.index(code)
      return true if unit_record[meta.unitname].index(code)
      for child in unit_record.children
        return true if includes?(taskstrid, tasktimeid, child.unitid, otype, code)
      end
      return false
    end
  end
end
