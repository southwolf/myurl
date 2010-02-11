# Methods added to this helper will be available to all templates in the application.
require "unit"

module ApplicationHelper
  def GetRootNodes(taskid, bypermission=true, show_hidden=false)
    result = Array.new
    task = Task.find(taskid)
    taskmeta = $TaskDesc[task.strid]
    UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{taskmeta.fmtable}".downcase)
    #allunits = Unit.find(:all, :conditions => "p_parent = '' or p_parent is null")
    if !bypermission
      allunits = UnitFMTableData.find(:all, :conditions => "p_parent = '' or p_parent is null")
      allunits.sort!
    else
      allunits = GetUnitForest(taskid, session[:user].id)
    end
    for unit in allunits            
        next if !show_hidden && unit["display"].to_s == '0'
        result << "tree" + unit.id
    end
    result
  end
  
  #检查用户的对单位的读权限
  def CheckUnitReadRight(taskid, userid, unitid)
    CheckUnitRight(taskid, userid, unitid) == 1 || CheckUnitRight(taskid, userid, unitid)== 3
  end
  
  #检查用户的对单位的写权限
  def CheckUnitWriteRight(taskid, userid, unitid)
    CheckUnitRight(taskid, userid, unitid) == 3
  end
  
  #判断用户的角色权限
  #userid:整形
  #right:字符串，如"任务管理"
  def CheckRight(userid, right)
    return true if YtaplUser.find(userid).name == "admin"
    
    moduleright = YtaplRight.find(:all, :conditions => "name = '#{right}'")
    #没有此权限则对所有用户返回真
    return if moduleright.size == 0
    
    role = YtaplRole.find(YtaplUser.find(session[:user].id).roleid)
    for roleright in role.rights
      return true if roleright.name == right
    end
    
    return false
  end
  
  #根据权限获得单位森林
  #userid,整型，用户id
  #返回ActiveRecord集合
  def GetUnitForest(taskid, userid)
    #根据用户id得到所有该用户有权限的单位
    units = GetUnitIDs(taskid, userid)
    units = ReduceUnit(units)
    units 
  end
  
  #返回有读权限的所有单位
  #taskid,整型，任务id
  #userid,整型，用户id
  #onlyid,true返回单位id集合
  #onlyid,false返回ActiveRecord集合
  def GetPermitUnits(taskid, userid, onlyid = true)
    units = GetUnitIDs(taskid, userid)
    units.sort!
    result = Array.new
    for unit in units
      result << unit
    end
    for unit in result
      for child in unit.children
        result << child
      end
    end
    p result.size
    if onlyid
      temp = Array.new
      for unit in result
        temp << unit.unitid
      end
      temp.sort!
      return temp
    else  
      return result
    end
    
  end
  
  def GenerateUnitTree(taskid, parent, controller, action, updatediv, target, bypermission=true, show_hidden=false) 
    task = Task.find(taskid)
    taskmeta = $TaskDesc[task.strid]
    UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{taskmeta.fmtable}".downcase)
    if !bypermission
      #allunits = UnitFMTableData.find(:all, :conditions => "p_parent = '#{parent}' #{'or p_parent is null' if parent==''}")
      units = UnitFMTableData.find(:all)
      allunits = Array.new
      for unit in units
        allunits<<unit if !unit.parent
      end
    else
      allunits = GetUnitForest(taskid, session[:user].id)
    end
    allunits.sort!
    @script = %Q!<script type="text/javascript">\n!
    for unit in allunits            
        next if !show_hidden && unit["display"].to_s == '0'
          
        link = url_for(:controller => controller, :action => action, :id =>unit.unitid)
        sublink = url_for(:controller => controller, :action => action)
        synlink = ""
        synlink = "/unittree/getchildunit/#{unit['unitid']}?sublink=#{sublink}&updatediv=#{updatediv}&target=#{target}&showhidden=#{show_hidden.to_s}" if unit.children.size > 0
        @script += %Q!var tree#{unit.id} = new WebFXLoadTree("#{unit[taskmeta.unitname]}", "#{synlink}", "#{link}");\n!
        
        @script += %Q!tree#{unit.id}.icon = "/img/icon_#{unit[taskmeta.reporttype]}.gif";\n!
        @script += %Q!tree#{unit.id}.openIcon = "/img/icon_#{unit[taskmeta.reporttype]}.gif"; \n!
        
        @script += %Q!tree#{unit.id}.setBehavior('classic');\n!
        
        if !target || target == ''
          @script += %Q!tree#{unit.id}.clickFunc="new Ajax.Updater('#{updatediv}', '#{link}', {asynchronous:true}); return false;"\n!
        end
        
        @script += %Q!tree#{unit.id}.target="#{target}";\n!if target && target!=""       
               
        @script += %Q!document.write(tree#{unit.id});! 
    end 
        
    @script += %Q!\n</script>!
    return @script
  end

  def GenerateCheckBoxUnitTree(taskid, parent, url, updatediv, target='', bypermission=true, show_hidden=false, select_array=nil) 
    task = Task.find(taskid)
    taskmeta = $TaskDesc[task.strid]
    UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{taskmeta.fmtable}".downcase)
    if !bypermission
      allunits = UnitFMTableData.find(:all, :conditions => "p_parent = '#{parent}' #{'or p_parent is null' if parent==''}")
    else
      allunits = GetUnitForest(taskid, session[:user].id)
    end
    allunits.sort!
    @script = %Q!<script type="text/javascript">\n!
    for unit in allunits            
        next if !show_hidden && unit["display"].to_s == '0'
      
        #link = url_for(:controller => controller, :action => action, :id =>unit.unitid)
        link = url
        #sublink = url_for(:controller => controller, :action => action)
        sublink = url
        synlink = ""
        synlink = "/unittree/getchildunit/#{unit['unitid']}?sublink=#{sublink}&updatediv=#{updatediv}&target=#{target}&showhidden=#{show_hidden.to_s}" if unit.children.size > 0
        
        value = 'false'
        value = 'true' if select_array && select_array.include?(unit.unitid)
        @script += %Q!var tree#{unit.id} = new WebFXCheckBoxLoadTree("#{unit[taskmeta.unitname]}", #{value}, '#{unit['unitid']}', "#{synlink}", "#{link}");\n!
        @script += %Q!tree#{unit.id}.icon = "/img/icon_#{unit[taskmeta.reporttype]}.gif";\n!
        @script += %Q!tree#{unit.id}.openIcon = "/img/icon_#{unit[taskmeta.reporttype]}.gif"; \n!
        
        @script += %Q!tree#{unit.id}.setBehavior('classic');\n!
        
        if !target || target == ''
          @script += %Q!tree#{unit.id}.clickFunc="new Ajax.Updater('#{updatediv}', '#{link}', {asynchronous:true}); return false;"\n!
        end
        
        @script += %Q!tree#{unit.id}.target="#{target}";\n!if target && target!=""       
               
        @script += %Q!document.write(tree#{unit.id});\n! 
    end         
    @script += %Q!\n</script>!
    return @script
  end

  def GenerateRadioUnitTree(taskid, parent, url, updatediv, target='', bypermission=true, show_hidden=false) 
    task = Task.find(taskid)
    taskmeta = $TaskDesc[task.strid]
    UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{taskmeta.fmtable}".downcase)
    if !bypermission
      allunits = UnitFMTableData.find(:all, :conditions => "p_parent = '#{parent}' #{'or p_parent is null' if parent==''}")
    else
      allunits = GetUnitForest(taskid, session[:user].id)
    end
    allunits.sort!
    @script = %Q!<script type="text/javascript">\n!
    for unit in allunits            
        next if !show_hidden && unit["display"].to_s == '0'
        
        
        #link = url_for(:controller => controller, :action => action, :id =>unit.unitid)
        link = url
        #sublink = url_for(:controller => controller, :action => action)
        sublink = url
        synlink = ""
        synlink = "/unittree/getchildunit/#{unit['unitid']}?sublink=#{sublink}&updatediv=#{updatediv}&target=#{target}&showhidden=#{show_hidden.to_s}" if unit.children.size > 0
                   #/application/getchildunit/#{unit['unitid']}?sublink=#{sublink}&updatediv=#{updatediv}&target=#{target}&showhidden=#{show_hidden.to_s}
        
        @script += %Q!var tree#{unit.id} = new WebFXRadioLoadTree("#{unit[taskmeta.unitname]}", true, '#{unit['unitid']}', "#{synlink}", "#{link}");\n!
        @script += %Q!tree#{unit.id}.icon = "/img/icon_#{unit[taskmeta.reporttype]}.gif";\n!
        @script += %Q!tree#{unit.id}.openIcon = "/img/icon_#{unit[taskmeta.reporttype]}.gif"; \n!
        
        @script += %Q!tree#{unit.id}.setBehavior('classic');\n!
        
        if !target || target == ''
          @script += %Q!tree#{unit.id}.clickFunc="new Ajax.Updater('#{updatediv}', '#{link}', {asynchronous:true}); return false;"\n!
        end
        
        @script += %Q!tree#{unit.id}.target="#{target}";\n!if target && target!=""       
               
        @script += %Q!document.write(tree#{unit.id});\n! 
    end 
        
    @script += %Q!\n</script>!
    return @script
  end

  #将tasktime表的一条记录转成描述字符串如:'2006年8月'
  #record是Yttasktime的一条记录
  def GetTaskTimeDescString(record)
    if record.endtime.month - record.begintime.month > 10 #年报
      return record.begintime.year.to_s +  '年'
    elsif record.endtime.month - record.begintime.month >2 #季报
      return record.begintime.year.to_s + '年第' + (record.begintime.month / 3).to_s + '季度'
    elsif record.endtime.mday - record.begintime.mday > 26 #月报
      return record.begintime.year.to_s + '年' + ("%02d" % record.begintime.month.to_s) + '月'
    end
  end
  
  #生成任务时间combobox
  #taskid:整型
  def TaskTimeCombo(taskid, action="submit()", selectid = -1)
    result = "<select id='tasktime' name='tasktime' onchange='#{action}'>"
    tasktimes = Yttasktime.find(:all, :conditions => "taskid = #{taskid}", :order => 'tasktimeid')
    first = tasktimes[0]
    
    now = Time.new
    if first.endtime.month - first.begintime.month > 10 #年报
      for tasktime in tasktimes
        selected = ""
        if selectid.to_s == "-1"
          selected = "selected" if now.year-tasktime.begintime.year==1
        else
          selected = "selected" if tasktime.id == selectid
        end
        result << "<option value='#{tasktime.id}' #{selected}>#{tasktime.begintime.year}年</option>"
      end
    elsif first.endtime.month - first.begintime.month >2 #季报
      for tasktime in tasktimes
      
      end
    elsif first.endtime.mday - first.begintime.mday > 26 #月报
      for tasktime in tasktimes
        selected = ""
        if selectid.to_s == "-1"
          selected = "selected" if now.at_beginning_of_month.last_month == tasktime.begintime
        else
          selected = "selected" if tasktime.id.to_s == selectid.to_s
        end
        result << "<option value='#{tasktime.id}' #{selected}>#{tasktime.begintime.year}年#{"%02d" % tasktime.begintime.month}月</option>"
        
      end    
    end
    result << "</select>"
    
    result
  end
  
  def ColorRow(index, id=nil)
     result = ""
     if index % 2 == 1
	    #result = "<tr class='TrLight' #{"id='#{id}'" if id} onmouseover=\"this.style.backgroundColor ='#FFFFCC'\"  onmouseout=\"this.style.color='';this.style.backgroundColor =''\"> "
	    result = "<tr class='TrLight' #{"id='#{id}'" if id} onmouseover=\"this.className ='Selected';\"  onmouseout=\"this.style.color='';this.className ='TrLight';\"> "
	 else
	    result = "<tr  #{"id='#{id}'" if id}  onmouseover=\"this.className ='Selected';\"  onmouseout=\"this.className='';\"> "
	 end
	 result
  end
  
private
  #检查用户的对单位的读写权限。返回整数1：可读，返回3：可写，返回0：不可读
  #taskid : 整形
  #parent表示是判断父节点权限还是子节点权限
  def CheckUnitRight(taskid, userid, unitid, parent=false)
    permissions = Ytunitpermissions.find_by_sql("select p.*
                          from ytapl_users u, ytapl_groups g, ytapl_groupmember m, ytapl_unitpermissions p
                          where m.userid = u.userid and m.groupid = g.groupid and g.groupid = p.groupid 
                          and p.taskid = #{taskid} and p.unitid = '#{unitid}' and u.userid = #{userid} and(endtime is null or endtime > '#{Time.new().strftime(("%Y-%m-%d"))}')")
    if permissions.size == 0
      task = Task.find(taskid)
      meta = $TaskDesc[task.strid]
      UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
      begin
        unit_record = UnitFMTableData.find(unitid)
      rescue
        return 0
      end
      return 0 if !unit_record.parent
      if parent || !['0','1'].include?(unitid[unitid.size-1,1])
        return CheckUnitRight(taskid, userid, unit_record.parent.unitid, true) 
      else
        return CheckUnitRight(taskid, userid, unit_record.parent.unitid, true) if CheckRight(session[:user].id, "查看底层单位数据")
      end
      return 0       
    end
    
    for permission in permissions
      if permission.permission == 3
        return 3
      else
        return 1
      end
      
      ##兼容问题，以前的java版本有一个-1，但不知道是什么意思，一律看成1，可读
      #if permission.permission == 1
      #  return 1
      #end
    end    
    return 0
  end
  
  #根据用户id获得有权限的单位集合,返回UnitFMTableData实例集合
  def GetUnitIDs(taskid, userid)
    result = Array.new
    
    task = Task.find(taskid)
    meta = $TaskDesc[task.strid]
    UnitFMTableData.set_table_name("ytapl_#{task.strid}_#{meta.fmtable}".downcase)
    
    members = Ytgroupmember.find(:all, :conditions=>"userid=#{userid}")
    for member in members
      permissions = Ytunitpermissions.find(:all, :conditions=>"taskid = #{taskid} and groupid = #{member.groupid} and (endtime is null or endtime > '#{Time.new().strftime("%Y-%m-%d")}')")
      for permission in permissions
        begin
        	result<<UnitFMTableData.find(permission.unitid) if permission.permission==1 || permission.permission==3
        rescue
        	#可能单位删了权限留着
        end
      end
    end
    
    result.uniq!
    result
  end
  
  #将不是根的单位去掉
  def ReduceUnit(units)
    result = Array.new
    for unit in units
      isChild = false
      for other in units        
        if unit.is_descendant_of(other)
          isChild = true
          break
        end
      end
      result << unit if !isChild
    end
    
    result
  end
end
