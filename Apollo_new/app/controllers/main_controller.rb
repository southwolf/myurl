require "EncodeUtil"
require "Table"
require "ScriptEngine"

class MainController < ApplicationController
  layout "main"
  def index
    session[:task] = session[:task] #||Task.find_first()   
    #没有任务
    if !session[:task]
    #  redirect_to :controller=>'group', :action=>'index'
       cookies = Ytcookie.find(:all, :conditions=>"addr='#{request.env_table['REMOTE_ADDR']}'")
       lasttask = nil
       p cookies
       if cookies.size > 0
        lasttask = cookies[0].lasttask
        begin
          lasttask = nil || Task.find(lasttask) 
        rescue
          lasttask=nil
        end
        p lasttask
        lasttask = nil if lasttask && lasttask.reserved1=="1"
       end
       #转到上次访问的任务
       if Task.find_first("reserved1 <> '1'")
       		if lasttask || lasttask == 0
       		 redirect_to :action=>"switchtask", :id=> lasttask
       		else
       		 redirect_to :action=>"switchtask", :id=> Task.find_first().id
       		end
       else
       		redirect_to :controller=>"group", :action=>"index"
       end
      return
    end
    
    #金额单位
    meta = $TaskDesc[session[:task].strid]
    @currency_base = session[:currency] || meta.helper.parameters['currency.base']

    session[:tasktime] = session[:tasktime] || GetDefaultTaskTime(session[:task].id).id
    session[:currenttask] = session[:task].taskid
  end
   
  #浏览单位数据的时候进行运算
  def calc
    @tasktimeid = session[:tasktime]  
    tasktimerecord = Yttasktime.find(session[:tasktime])
    session[:unitid] = params[:id] if params[:id]
    @unitid = session[:unitid]
    ##通过tastimeid 和 unitid获得数据

    records = _GetUnitData(session[:task].strid,  @unitid, @tasktimeid)
      
    meta = $TaskDesc[session[:task].strid]
    helper = meta.helper
    
    if (session[:task].activescriptsuitname.to_s != "")
        scripts = Ytscript.find(:all, :conditions=>"taskid = #{session[:task].taskid} and name = '#{session[:task].activescriptsuitname}'")
        if scripts.size > 0
          scriptstr = scripts[0].content    #获得xml文本串
          script = CTaskScript.new          #生成CTaskScript对象
          script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
          scriptengine = TaskScriptEngine.new(session[:task].strid, script, @unitid, tasktimerecord.begintime, helper.tables, records)
          scriptengine.Prepare
          scriptengine.ExecuteAllCalc()
          flash[:notice] = "运算成功"
        else
          flash[:error] = "找不到激活脚本"
        end
    else
      flash[:error] = "没有激活脚本"
    end
    getunitdata()
  end
  
  #切换任务
  def switchtask
    session[:currenttask] = params[:id]
    
    #保存cookie信息
    cookies = Ytcookie.find(:all, :conditions=>"addr='#{request.env_table['REMOTE_ADDR']}'")
    if cookies.size > 0
      cookies[0].lasttask = params[:id].to_i
      cookies[0].save
    else
      cookie = Ytcookie.new
      cookie.addr = request.env_table['REMOTE_ADDR']
      cookie.lasttask = params[:id]
      cookie.save
    end    
    
    if session[:currenttask].to_i == -1  #系统安全管理
      redirect_to :controller=>'group', :action=>'index'
      return
    elsif session[:currenttask].to_i == -2  #任务管理
      redirect_to :controller=>'taskman', :action=>'index'
      return
    elsif session[:currenttask].to_i == -3  #安全日志管理
      redirect_to :controller=>'log', :action => 'index'
      return
    elsif session[:currenttask].to_i == -4  #bbs留言板
      redirect_to :controller=>'bbsmessage', :action => 'index'
      return
    elsif session[:currenttask].to_i == -5  #指标解释
      redirect_to :controller=>'scalarexplain', :action => 'index'
      return
    elsif session[:currenttask].to_i == -6  #最新通知
      redirect_to :controller=>'ytnews', :action => 'index'
      return
    elsif session[:currenttask].to_i == -7  #私人文件夹
      redirect_to :controller=>'fileshare', :action => 'index'
      return
    elsif session[:currenttask].to_i == 0 #决算
      YtLog.info "http://#{$RONGRUN_HOST}:8123/mof/lib/logon_new.jsp?username=#{session[:user].name}&pwd=#{session[:pwd]}"
      redirect_to "http://#{$RONGRUN_HOST}:8123/mof/lib/logon_new.jsp?username=#{session[:user].name}&pwd=#{session[:pwd]}"
      return
    elsif session[:currenttask].to_i == -8  #统计公报
      redirect_to :controller=>'statisticreport', :action => 'index'
      return
    elsif session[:currenttask].to_i == -9 #数据备份
      redirect_to :controller=>'ytwg_backup', :action => 'index'
      return
    end
    
    begin
      session[:task] = Task.find(params[:id])
    rescue
      ##如果上次访问的任务现在已经不存在，则转到第一个任务
      session[:task] = Task.find_first()
    end
    session[:task].view = ""
    session[:tasktime] = GetDefaultTaskTime(session[:task].id).id
    redirect_to :controller=>'main', :action => 'index'
  end
  
  #切换任务时间
  def switchtasktime
    session[:tasktime]=params[:tasktime]
    getunitdata
  end
  
  #获得单位数据
  def getunitdata   
    @tasktimeid = params[:taskTimeID] || session[:tasktime]  
    session[:unitid] = params[:id] if params[:id]
    @unitid = params[:unitID] || session[:unitid]   #审核的时候直接传入unitID参数查看结果
    Ytfillstate.set_table_name(:ytapl_fillstate)
    @filled = Ytfillstate.find [@unitid, session[:task].strid, @tasktimeid] rescue nil
    ##通过tastimeid 和 unitid获得数据
  
    meta = $TaskDesc[session[:task].strid]
    helper = meta.helper
    @yttables = helper.tables
    @htmls = Array.new
    count = 0
    for table in helper.tables
      if count == 0
        UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase)
        UnitFMTableData.reset_column_information
        unitdata = UnitFMTableData.find(@unitid) rescue nil
        @fm = unitdata
        @unitname = "单位名称："+unitdata[meta.unitname] rescue nil
      else
        UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase)
        UnitTableData.reset_column_information
        unitdata = UnitTableData.find [@unitid,@tasktimeid] rescue nil        
      end
      count += 1
      session[:currency] = params[:currency] || session[:currency]
      @htmls << helper.TableToEditHTML(table, helper.dictionFactory, {:script=>helper.script, :encoding=>"utf-8", :readonly=>true, :only_table_tag=>true, :record=>unitdata, :currency=>session[:currency]})
    end
    
    #获得报告模板
    @articles = Ytarticletemplate.find(:all, :conditions=>"taskid = '#{session[:task].strid}'")
    
    #获得附件
    AttachmentTableData.set_table_name("ytapl_#{session[:task].strid}_attachment".downcase)
    @attachments = AttachmentTableData.find(:all, :conditions=>"unitid = '#{session[:unitid]}' and tasktimeid = #{session[:tasktime]}")
    
    if session[:last_task] != session[:task].name
      @switch_flag = true
      session[:last_task] = session[:task].name
    end
    render :action=>'getunitdata',:layout =>false
  end
  
  #生成报告
  def make_article
    begin
    	article = Ytarticletemplate.find(params[:id].to_i)
    rescue
    	redirect_to :action=>'index'
    	return
    end
    
    tasktime = Yttasktime.find(session[:tasktime].to_s.to_i)
    result = article.context
    result = result.gsub(/#.*\s*\\\{year\\\}/, tasktime.begintime.year.to_s)
    result = result.gsub(/#.*\s*\\\{month\\\}/, tasktime.begintime.month.to_s)
    result = result.gsub(/#.*\s*\\\{date\\\}/, tasktime.begintime.mday.to_s)
    
    datas = _GetUnitData(session[:task].strid, session[:unitid], session[:tasktime])
    
    meta = $TaskDesc[session[:task].strid]
    
    index = 0
    for data in datas
      data.attributes.each{|key, value|
        table = meta.helper.tables()[index]
        #result = result.gsub(/#.*\\*\{.*#{table.GetTableID().downcase}\.#{key.downcase}\\\}/, value.to_s)
        result = result.gsub(/#\\\{#{table.GetTableID().downcase}\.#{key.downcase}\\\}/, value.to_s)
        #result = result.gsub("\#\\{#{table.GetTableID().downcase}.#{key.downcase}\\}", value.to_s)
     }
     index += 1
    end
    send_data result, :filename =>"article.doc"
  end
  
  #输入单位数据
  def inputunitdata
    meta = $TaskDesc[session[:task].strid]
    @taskcontent = ZipAndBase64(EncodeUtil.change("GB2312", "UTF-8", meta.view))
    @tasktime = Yttasktime.find(session[:tasktime])
    @unitid = params[:unitID]
    if params[:readonly] == "1"
      @readonly = "false"
    else
      @readonly = "true"
    end
    
    
    
    #为了07国资委快报特殊化处理
    p "ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
    UnitFMTableData.reset_column_information
    @fm = UnitFMTableData.find(@unitid) rescue nil
    
    
    render :action=>'inputunitdata', :layout => false
  end
  
  def selunittype
    render :action => 'selunittype', :layout =>"popup"
  end

  def download_excel
    meta = $TaskDesc[session[:task].strid]
    records = _GetUnitData(session[:task].strid, session[:unitid], session[:tasktime], true)
    if !params[:id]   #导出所有表
      newtables = Array.new
      
      index = 0
      for table in meta.helper.tables
        dupTable = CTable.new(StyleManager.new, "table1", "t1")
        dupTable.Copy(table)
        newtables << dupTable
        SetTableData(dupTable, records[index]) if records.size > 0
        index += 1
      end 
      
      send_file meta.helper.ExportToExcel(newtables, meta.helper.dictionFactory, session), :filename =>(session[:unitid]||'tables') + ".xls"
    else
      index = 0
      for table in meta.helper.tables
        if table.GetTableID() == params[:id]
          dupTable = CTable.new(StyleManager.new, "table1", "t1")
          dupTable.Copy(table)
          SetTableData(dupTable, records[index]) if records.size > 0
          
          send_file meta.helper.ExportToExcel([dupTable], meta.helper.dictionFactory, session), :filename =>(session[:unitid]||"") + "#{table.GetTableID()}.xls"
          break
        end
        index += 1
      end
    end
  end
  
  def download_pdf
    meta = $TaskDesc[session[:task].strid]
    records = _GetUnitData(session[:task].strid, session[:unitid], session[:tasktime], true)
      
    if !params[:id]   #导出所有表
      newtables = Array.new
      
      index = 0
      for table in meta.helper.tables
        dupTable = CTable.new(StyleManager.new, "table1", "t1")
        dupTable.Copy(table)
        newtables << dupTable
        SetTableData(dupTable, records[index]) if records.size > 0
        index += 1
      end 
      
      send_file meta.helper.ExportToPDF(newtables, meta.helper.dictionFactory), :filename =>(session[:unitid]||'tables') + ".pdf"
    else
      index = 0
      for table in meta.helper.tables
        if table.GetTableID() == params[:id]
          dupTable = CTable.new(StyleManager.new, "table1", "t1")
          dupTable.Copy(table)
          SetTableData(dupTable, records[index]) if records.size > 0
          send_file meta.helper.ExportToPDF([dupTable], meta.helper.dictionFactory), :filename =>session[:unitid] + "#{table.GetTableID()}.pdf"
          break
        end
        index += 1
      end
    end
  end

  def get_float_table
    require "Util"
    @records = Util.GetFloatPage(session[:task].strid, params[:tableid], params[:float_id], session[:unitid], session[:tasktime], params[:page].to_i)
    
    meta = $TaskDesc[session[:task].strid]
    helper = meta.helper
    for table in helper.tables
      if table.GetTableID() == params[:tableid]
        UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase)
        begin
          unitdata = UnitTableData.find [session[:unitid], session[:tasktime]] 
        rescue
        ensure
          float_hash = Hash.new
          float_hash[params[:float_id].to_i] = @records
          html = helper.TableToEditHTML(table, helper.dictionFactory, {:encoding=>"utf-8", :readonly=>true, :only_table_tag=>true, :record=>unitdata, :float_record => float_hash})
          @unitid = session[:unitid]
          @tasktimeid = session[:tasktime]
          render :partial=>'getfloatrows', :locals=>{:yttable=>table, :html=>html, :current_page=>params[:page].to_i}
          break          
        end
      end
    end
  end
  
  def add_float_row
    UnitFloatTableData.set_table_name("ytapl_#{session[:task].strid}_#{params[:table]}_#{params[:float_id]}".downcase)
    UnitFloatTableData.reset_column_information
    datas = UnitFloatTableData.find(:all, :conditions=>"unitid='#{session[:unitid]}' and tasktimeid=#{session[:tasktime]}", :limit=>1, :order=>'float_id desc')
    float_id = 1
    if datas.size > 0
      float_id = datas[0].float_id.to_s.to_i + 1
    end
    data = UnitFloatTableData.new
    data.float_id = float_id
    data.unitid = session[:unitid]
    data.tasktimeid = session[:tasktime]
    data.save
    redirect_to :action=>"get_float_table", :tableid=>params[:table],:float_id=>params[:float_id], :page=>params[:page]
  end
  
  #上传附件
  def upload_attachment
    AttachmentTableData.set_table_name("ytapl_#{session[:task].strid}_attachment")
    attach = AttachmentTableData.new(params[:attachment])
    attach.unitid = session[:unitid]
    attach.tasktimeid = session[:tasktime]
    if !attach.path
      flash[:error] = "上传附件错误"
      redirect_to :action=>'getunitdata'
      return
    end
    attach.name = File.basename(attach.path)
    attach.save
    flash[:notice] = "上传附件成功"
    
    #@attachments = AttachmentTableData.find(:all, :conditions=>"unitid = '#{session[:unitid]}' and tasktimeid = #{session[:tasktime]}")
    #render :partial =>'attachment', :locals=>{:attachments=>@attachments}
    
    redirect_to :action=>'getunitdata'
  end
  
  #下载附件
  def download_attachment
    AttachmentTableData.set_table_name("ytapl_#{session[:task].strid}_attachment")
    attachment = AttachmentTableData.find(params[:id])
    send_file attachment.path
  end
  
  #删除附件
  def delete_attachment
    AttachmentTableData.set_table_name("ytapl_#{session[:task].strid}_attachment")
    AttachmentTableData.find(params[:id]).destroy
    @attachments = AttachmentTableData.find(:all, :conditions=>"unitid = '#{session[:unitid]}' and tasktimeid = #{session[:tasktime]}")
    render :partial =>'attachment', :locals=>{:attachments=>@attachments}
  end
  
  #页面编辑功能
  def update
    parts=params[:cell].split('.')
    table = parts[0]
    cell = parts[1]
    meta = $TaskDesc[session[:task].strid]
    
    #修改浮动行数据
    if params[:floattpl]
      UnitFloatTableData.set_table_name("ytapl_#{session[:task].strid}_#{table}_#{params[:floattpl]}".downcase)
      UnitFloatTableData.reset_column_information
      data = UnitFloatTableData.find [session[:unitid],session[:tasktime], params[:floatindex] ] rescue nil
      if data
        data[cell] = params[:value]
        data.save
        data.reload
        render :text=> data[cell].to_s
        return
      end
      render :text=>' '
    end
    
    
    
    begin
    if meta.helper.tables[0].GetTableID().to_s == table.to_s
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{table}".downcase)
      data = UnitFMTableData.find session[:unitid]
    else
      
      UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table}".downcase)
      data = UnitTableData.find [session[:unitid], session[:tasktime]] rescue nil
      #还没填数
      if !data
       
       #每张表加本期数据的一个记录
       1.upto(meta.helper.tables.size()-1) do |index|
          yttable = meta.helper.tables[index]
          UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{yttable.GetTableID()}".downcase)
          UnitTableData.reset_column_information
          data = UnitTableData.new
          data.unitid = session[:unitid]
          data.tasktimeid = session[:tasktime].to_i
          data.save
       end
       UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table}".downcase)
       UnitTableData.reset_column_information
       data = UnitTableData.find [session[:unitid], session[:tasktime]]
      end
    end
    data[cell] = params[:value]
    data.save
    data.reload
    render :text=> data[cell].to_s
    rescue Exception=>error
       render :text=>error.to_s
    end
    
  end
  
  def delete_data
    meta = $TaskDesc[session[:task].strid]
    helper = meta.helper
    for table in helper.tables
      next if table == helper.tables[0]
      UnitTableData.set_table_name("ytapl_#{session[:task].strid}_#{table.GetTableID()}".downcase)
      data = UnitTableData.find [params[:unitid], params[:tasktime]] rescue nil
      data.destroy if data
      
      #如果是浮动表，则删除浮动行明细数据
      if table.IsFloatTable()
        Integer(0).upto(table.GetRowCount()-1) do |row|
            logicRow = table.PhyRowToLogicRow(row+1)
            
            if table.IsFloatTemplRow(row)
              require "Util"
              records = Util.GetFloatData(session[:task].strid, table.GetTableID(), logicRow, params[:unitid], params[:tasktime], 1, 50000)
              for record in records
                record.destroy 
              end
            end
	    end
      end
      
    end
    fillinfo = Ytfillstate.find [params[:unitid], session[:task].strid, params[:tasktime]] rescue nil
    fillinfo.destroy if fillinfo
    flash[:notice] = "删除数据成功"
    redirect_to :action=>'getunitdata', :taskTimeID=>params[:tasktime], :unitID=>params[:unitID]
  end
  
  #上报
  def set_filled
    fillinfo = Ytfillstate.find [params[:unitid], session[:task].strid, params[:tasktime]] rescue nil
    if !fillinfo
      #先审核是否通过
      #有激活脚本
      YtLog.info "fill info not found"
      if session[:task].activescriptsuitname.to_s != ""
        scripts = Ytscript.find(:all, :conditions=>"taskid = #{session[:task].taskid} and name = '#{session[:task].activescriptsuitname}'")
        #脚本存在
        if scripts.size > 0
          YtLog.info "script.size > 0"
          scriptstr = scripts[0].content    #获得xml文本串
          script = CTaskScript.new          #生成CTaskScript对象
          script.parse(EncodeUtil.change("GB2312", "UTF-8", scriptstr))
          meta = $TaskDesc[session[:task].strid]
          tasktimeid = params[:tasktime]
          tasktimerecord = Yttasktime.find(params[:tasktime])
          unit = params[:unitid]
          errors = Array.new
          warns = Array.new
          @unit_error_warn = Hash.new
          records = _GetUnitData(session[:task].strid, unit, tasktimeid, false) #没填的数据不取
          if records.size > 0
            scriptengine = TaskScriptEngine.new(session[:task].strid, script, unit, tasktimerecord.begintime, meta.helper.tables, records)
            scriptengine.Prepare
            scriptengine.ExecuteAllAudit()
            for error in scriptengine.GetErrors()
              errors << error
            end
            @unit_error_warn[unit] = [errors, warns, unit]
            if errors.size > 0
              @msgtype = "error"
              render :template=>"/audit/audit_input", :layout=>false
              return
            end
          end
        end
      end
      
      
      fillinfo = Ytfillstate.new
      fillinfo.unitid = params[:unitid]
      fillinfo.taskid = session[:task].strid
      fillinfo.tasktimeid = params[:tasktime]
      fillinfo.filldate = Time.new
      fillinfo.flag = 4
      fillinfo.save
    else
      render :text=>"<span id='pass' style='font-size:10pt'>数据已经上报了！</span>
    <script>
        setTimeout('new Effect.Puff(\"pass\")',4250)
    </script>"
    
      return
    end
    render :text=>"<span id='pass' style='font-size:10pt'>上报数据成功！</span>
    <script>
        setTimeout('new Effect.Puff(\"pass\")',4250)
    </script>"
  end
  
  
  #数据透视
  def pivot
    @cells = params[:cells].split(',')
    table_name = @cells[0].split('.')[0]
    
    meta = $TaskDesc[session[:task].strid]
    if meta.helper.tables[0].GetTableID().downcase == table_name.downcase
      render :text=>"封面表不能进行数据透视", :layout=>'popup'
      return
    end
    
    table_name = "ytapl_#{session[:task].strid}_" +@cells[0].split('.')[0]
    UnitTableData.set_table_name(table_name.downcase)
    UnitTableData.reset_column_information()
    @tasktimes = Yttasktime.find(:all, :conditions=>"taskid=#{session[:task].id} and tasktimeid<=#{params[:tasktimeid]}")
    @matrix = Hash.new
    for tasktime in @tasktimes
      states = Ytfillstate.find(:all, :conditions=>"unitid='#{params[:id]}' and taskid='#{session[:task].strid}' and tasktimeid = #{tasktime.id}")
      next if states.size == 0
      key = GetTaskTimeDescString(tasktime)
      records = UnitTableData.find(:all, :conditions=>"unitid = '#{params[:id]}' and tasktimeid = #{tasktime.id}")
      if records.size > 0
        @matrix[key] = records[0]
      else
        @matrix[key] = nil
      end
    end
    
    
    #尝试获得单元格描述
    @scalars = Array.new
    for table in meta.helper.tables
        if table.GetTableID().downcase == @cells[0].split('.')[0].downcase
          for cell in @cells
            rowcol = table.GetCellByFieldName(cell.split('.')[1])
            if rowcol[0] >0 && table.GetCell(rowcol[0], rowcol[1]).GetDescription().size>0
              @scalars << table.GetCell(rowcol[0], rowcol[1]).GetDescription
            else
              @scalars << cell.split('.')[1]
            end
          end
          
          break
        end
      end
    
    begin 
      UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.helper.tables[0].GetTableID()}".downcase)
      UnitFMTableData.reset_column_information
      unitdata = UnitFMTableData.find(params[:id]) 
      @unitname = unitdata[meta.unitname] 
    rescue 
    end
    
    render :layout=>'popup'
  end
  
  #数据透视:同级单位对比
  def pivot2
    @cells = params[:cells].split(',')
    table_name = "ytapl_#{session[:task].strid}_" +@cells[0].split('.')[0]
    UnitTableData.set_table_name(table_name.downcase)
    UnitTableData.reset_column_information()
    
    @meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{@meta.helper.tables[0].GetTableID()}".downcase)
    UnitFMTableData.reset_column_information
    
    @selunit = UnitFMTableData.find(params[:id])
    parent = @selunit.parent
    if !parent
      flash[:notice] = '根单位无法进行同级单位比较'
      @nilparent = true
      render :layout=>'popup'
      return
    end
    @children = parent.children
    
    @matrix = Hash.new
    for child in @children
      next if !CheckUnitReadRight(session[:task].id, session[:user].id, child.unitid)
      begin
      state = Ytfillstate.find [params[:id], session[:task].strid, params[:tasktimeid]] rescue nil
      rescue
        next
      end
      
      begin
        if table_name.downcase == @meta.helper.tables[0].GetTableID().downcase
          data = UnitFMTableData.find child['unitid']
        else
          data = UnitTableData.find [child['unitid'], params[:tasktimeid]]
        end
      rescue
        data = nil
      end
      @matrix[child] = data
    end
        
    #尝试获得单元格描述
    @scalars = Array.new
    meta = $TaskDesc[session[:task].strid]
    for table in meta.helper.tables
        if table.GetTableID().downcase == @cells[0].split('.')[0].downcase
          for cell in @cells
            rowcol = table.GetCellByFieldName(cell.split('.')[1])
            if rowcol[0] >0 && table.GetCell(rowcol[0], rowcol[1]).GetDescription().size>0
              @scalars << table.GetCell(rowcol[0], rowcol[1]).GetDescription
            else
              @scalars << cell.split('.')[1]
            end
          end
          
          break
        end
      end
    
    render :layout=>'popup'
  end
  
private
  def SetTableData(table, record)
    for field in record.attribute_names
      rowcol = table.GetCellByFieldName(field)
      next if rowcol[0] == -1
      table.SetCellValue(rowcol[0], rowcol[1], EncodeUtil.change("GB2312", "UTF-8", record[field].to_s))
    end
  end  
end
