require "Script"
require "ScriptEngine"

class AuditController < ApplicationController
  layout "main"
  #审核界面的审核功能
  def audit_audit
    @unit_error_warn = Hash.new
    #判断是否有活动脚本
    if (session[:task].activescriptsuitname.to_s == "")
      
      if params[:input]
        render :text => "当前任务没有激活脚本 ", :layout=>false
      else
        flash[:error] = '当前任务没有激活脚本'
        render :action => 'audit_audit', :layout => 'subwindow'
      end
      return
    end
    
    
    scripts = Ytscript.find(:all, :conditions=>"taskid = #{session[:task].taskid} and name = '#{session[:task].activescriptsuitname}'")
    if scripts.size == 0
      if params[:input]
        render :text => "激活脚本不存在 ", :layout=>false
      else
        flash[:error] = '激活脚本不存在'
        render :action => 'audit_audit', :layout => 'subwindow'
      end
      return
    end
    scriptstr = scripts[0].content    #获得xml文本串
    script = CTaskScript.new          #生成CTaskScript对象
    script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
    
    meta = $TaskDesc[session[:task].strid]
    tasktimeid = params[:tasktime]
    tasktimerecord = Yttasktime.find(params[:tasktime])
    units = params[:unitIDs].split(',')    
    realunits = GetUnits(session[:task].strid, units, params[:flag])
    for single in realunits
      unit = single.unitid
      print "---------audit #{unit}-------\n"
      errors = Array.new
      warns = Array.new
      records = _GetUnitData(session[:task].strid, unit, tasktimeid, false) #没填的数据不取
      @unit_error_warn[unit] = [nil, nil, single[meta.unitname]]
      next if records.size == 0
      
      scriptengine = TaskScriptEngine.new(session[:task].strid, script, single, tasktimerecord.begintime, meta.helper.tables, records)
      scriptengine.Prepare
      scriptengine.ExecuteAllAudit()
      for error in scriptengine.GetErrors()
        errors << error
      end
      
      for warn in scriptengine.GetWarns()
        warns << warn
      end

      p errors
      p warns
      @unit_error_warn[unit] = [errors, warns, records[0][meta.unitname]]
      
      #在审核信息表中写入相应信息(人民日报要求审核完立即写入结果),添加了一个权限，有此权限才能写入审核标志
      if params[:input] != 'true' && CheckRight(session[:user].id, '写入审核标志')
        begin
          info = Ytauditinfo.find [unit, session[:task].strid, tasktimeid]
        rescue
          info = Ytauditinfo.new
          info.unitid = unit
          info.taskid = session[:task].strid
          info.tasktimeid = tasktimeid
        end
        info = Ytauditinfo.new if !info
        info.auditdate = Time.new
        info.auditor = session[:user].truename
        info.flag =  errors.size > 0 ? 0 : 1 
        info.save
      end
    end   
    @tasktimeid = tasktimeid
    @msgtype = params[:msgtype]
    
    if params[:input] == 'true'
      @msgtype = 'alltype'
      render :action => 'audit_input', :layout=>false
    else
      flash[:notice] = "审核完毕"
      render :action => 'audit_audit', :layout => 'subwindow'
    end
  end
  
  #只置审核通过标志
  def save_audit
    @unitids = params[:unitIDs].split(',')
    @result_size = 0
    @error_text = Array.new
    #meta = $TaskDesc[session[:task].strid]
    for unitid in @unitids
      unitdatas=_GetUnitData(session[:task].strid, unitid, params[:tasktime], false)
      if unitdatas.size == 0    
        @error_text << "单位#{unitid}本期时间没有录入数据,不能审核。"        
        next
      end
      begin
        info = Ytauditinfo.find [unitid, session[:task].strid, params[:tasktime] ]
        rescue
          info = Ytauditinfo.new
          info.unitid = unitid
          info.taskid = session[:task].strid
          info.tasktimeid = params[:tasktime]
        end
        info.auditor = session[:user].name
        info = Ytauditinfo.new if !info
        info.auditdate = Time.new
        if params[:auditresult] == "true"
          info.flag = 1
        else
          info.flag = 0
        end
        info.save
        @result_size += 1
      end
      
     if @result_size > 0 
      flash[:notice] = "审核结果保存成功"
     else
      flash[:error] = "审核结果保存失败"
     end
     render :layout => 'subwindow'
  end
  
  #审核界面的计算功能
  def audit_calc
    meta = $TaskDesc[session[:task].strid]
    tasktimeid = params[:tasktime]
    units = params[:unitIDs].split(',')    
    tasktimerecord = Yttasktime.find(params[:tasktime])
    
    #判断是否有活动脚本
    if (session[:task].activescriptsuitname.to_s == "")
      flash[:error] = '当前任务没有激活脚本'
      render :action => 'audit_calc', :layout => 'subwindow'
      return
    end
    
    scripts = Ytscript.find(:all, :conditions=>"taskid = #{session[:task].taskid} and name = '#{session[:task].activescriptsuitname}'")
    if scripts.size == 0
      flash[:notice] = '激活脚本不存在'
      render :action => 'audit_calc', :layout => 'subwindow'
    end
    scriptstr = scripts[0].content    #获得xml文本串
    script = CTaskScript.new          #生成CTaskScript对象
    script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
    
    @audit_count = 0
    for unit in units
      
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
      UnitFMTableData.reset_column_information() 
      calcunit = UnitFMTableData.find(unit) rescue nil
    
      if calcunit.BBLX=='1'
        records = _GetUnitData(session[:task].strid, unit, tasktimeid, true)
      else
        records = _GetUnitData(session[:task].strid, unit, tasktimeid, false)
      end
      next if records.size == 0
      
      scriptengine = TaskScriptEngine.new(session[:task].strid, script, unit, tasktimerecord.begintime, meta.helper.tables, records)
      scriptengine.Prepare
      scriptengine.ExecuteAllCalc()
      @audit_count += 1
    end
    
    flash[:notice] = "计算完毕"
    render :action => 'audit_calc', :layout => 'subwindow'
  end
  
end
