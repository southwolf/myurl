require 'rexml/document'
require 'Script'

include ApplicationHelper
class TaskmanController < ApplicationController
  before_filter :check_right
  layout "subwindow"
  
  def check_right
    if !CheckRight(session[:user].id, '管理任务')
      flash[:error] = "对不起，权限不足！"
      redirect_to :controller=>'application', :action=>'noprevilege_request' 
    end
  end
  
  def index
    @tasks = Task.find(:all, :order => "position")
    render :layout => 'taskman'
  end
  
  #任务设置页
  def publish_task
    @tasks = Task.find(:all, :order=>"position")
    render :action=> 'publish_task'
  end
  
#########################模板管理#############################  
  def template_manager
    session[:task] = Task.find(params[:id]) if params[:id]
    @templates = Ytreporttemplate.find(:all, :conditions=>"taskid = '#{session[:task].strid}'", :order=>"templateid")
  end
  
  def destroy_template
    Ytreporttemplate.find(params[:id]).destroy
    Ytreportresult.delete_all("templateid=#{params[:id]}")
    flash[:notice] = "删除查询模板成功"
    redirect_to :action => 'template_manager'
  end
  
  def uploadtemplate
    stream = params[:file]
    xmlstr = stream.read
    report = Ytreporttemplate.new
    report.templatename = stream.original_filename[0, stream.original_filename.index(".")]
    report.taskid = session[:task].strid
    report.createtime = Time.new
    report.content = EncodeUtil.change("UTF-8", "GB2312", xmlstr)
    report.save
    
    flash[:notice] = "查询模板发布成功"
    redirect_to :action => 'template_manager'
  end
  
  def export_template
    templateid = params[:id]
    template = Ytreporttemplate.find(params[:id].to_i)
    str = EncodeUtil.change("GB2312", "UTF-8", template.content)
    send_data str, :filename => "template.xml"
  end
################################################################
  
  
#######################报告管理##################################  
  def article_manager
    session[:task] = Task.find(params[:id]) if params[:id]
    @templates = Ytarticletemplate.find(:all, :conditions=>"taskid = '#{session[:task].strid}'")
  end
    
  def upload_article
    stream = params[:file]
    context = stream.read
    article = Ytarticletemplate.new
    article.taskid = session[:task].strid
    article.name = File.basename(stream.original_filename, ".rtf")
    article.publishtime = Time.new
    article.context = context
    article.save
    flash[:notice] = "报告模板发布成功"
    redirect_to :action => 'article_manager'
  end
  
  def export_article
    article = Ytarticletemplate.find(params[:id])
    send_data article.context, :filename => article.name + ".doc"
  end
  
  def destroy_article
    Ytarticletemplate.find(params[:id]).destroy
    flash[:notice] = "报告模板成功"
    redirect_to :action => 'article_manager'
  end
######################3#权限管理页面###############################
  def permition_manager
    session[:task] = Task.find(params[:id]) if params[:id]
    @current_group = params[:group].to_i
    if @current_group
      #@permission_units = Ytunitpermissions.find(:all, :joins=>"", :conditions=>"groupid=#{@current_group} and taskid=#{session[:task].id}") 
      meta = $TaskDesc[session[:task].strid]
      @permission_units = Ytunitpermissions.find_by_sql("select p.*, f.#{meta.unitname}
                                                        from ytapl_unitpermissions p 
                                                left join ytapl_#{session[:task].strid.downcase}_#{meta.fmtable.downcase} f on f.unitid = p.unitid 
                                                where p.groupid=#{@current_group} and p.taskid=#{session[:task].id}")
      @unit_name_field = meta.unitname
     end
  end
  
  #分配权限
  def endure_right
    flag = params[:rightFlag] #1:读权限, 2:读写权限
    group = params[:groupID]  #组id
    units = params[:unitIDs].split(',')
    taskid = session[:task].id
    for unit in units
      Ytunitpermissions.delete_all("groupid = #{group} and taskid=#{taskid} and unitid = '#{unit}'")
      permission = Ytunitpermissions.new
      permission.groupid = group
      permission.taskid = taskid
      permission.unitid = unit
      if flag.to_s == "1"
        permission.permission = 1
      elsif flag.to_s == "2"
        permission.permission = 3
      end
      permission.save
    end
    flash[:notice] = '分配权限成功'
    redirect_to :action=>'permition_manager', :group =>params[:groupID]
  end
  
  #改变权限
  def change_right
    unitid = params[:unitID]
    groupid = params[:groupID]
    writeFlag = params[:writeFlag]=="true"
    permission = Ytunitpermissions.find [groupid, session[:task].id, unitid]
    permission.endtime = params[:endTime] if params[:endTime].size > 0
    if writeFlag
      permission.permission = 3
    else
      permission.permission = 1
    end
    permission.save
    flash[:notice] = '修改权限成功'
    redirect_to :action=>'permition_manager', :group =>groupid
  end
  
  #删除权限
  def delete_right
    unitid = params[:unitID]
    groupid = params[:groupID]
    permission = Ytunitpermissions.find [groupid, session[:task].id, unitid]
    permission.destroy
    flash[:notice] = '删除权限成功'
    redirect_to :action=>'permition_manager', :group =>groupid
  end
#################################################################  
  
####################################更新表样######################
  def style_manager
    session[:task] = Task.find(params[:id]) if params[:id]
  end
  
  def upload_style
    stream = params[:file]
    xmlstr = stream.read
    task = Task.find(session[:task].id)
    task.view = EncodeUtil.change("UTF-8", "GB2312", xmlstr)
    task.save
    #$TaskDesc[session[:task].strid].view = task.view
    TaskMeta.LoadTask(session[:task].id)
    flash[:notice] = '更新表样成功'
    redirect_to :action=>'style_manager'
  end
#################################################################  

###################发布脚本#######################################
  def script_manager
    session[:task] = Task.find(params[:id]) if params[:id]
    actives=Ytscript.find(:all, :conditions=>"taskid=#{session[:task].id} and name='#{session[:task].activescriptsuitname}'")
    if actives.size > 0
      @active = actives[0]
    end
    @scripts = Ytscript.find(:all, :conditions=>"taskid=#{session[:task].id}", :order=>"scriptid")
  end
  
  def publish_script
    stream = params[:file]
    xmlstr =  stream.read
    doc = Document.new(xmlstr)
    name = doc.root.attributes['name']
    scripts = Ytscript.find(:all, :conditions=>"taskid=#{session[:task].id} and name = '#{name}'")
    if scripts.size > 0
      flash[:notice] = '发布失败，存在同名脚本'
      redirect_to :action=>'script_manager', :id => session[:task].id
      return
    end
    script = Ytscript.new
    script.taskid = session[:task].id
    script.publishtime = Time.new
    script.content = EncodeUtil.change("UTF-8", "GB2312", xmlstr)
    script.name = name
    script.save
    
    flash[:notice] = '发布脚本成功'
    redirect_to :action=>'script_manager', :id => session[:task].id
  end
  
  def delete_script
    script = Ytscript.find(params[:id])
    if script.destroy
      flash[:notice] = '删除脚本成功'
    else
      flash[:notice] = '删除脚本失败'
    end
    redirect_to :action=>'script_manager', :id => session[:task].id
  end
  
  def active_script
    script = Ytscript.find(params[:id])
    
    task = Task.find(session[:task].id)
    task.activescriptsuitname = script.name
    task.save
    
    session[:task].activescriptsuitname = script.name
    
    redirect_to :action=>'script_manager', :id => session[:task].id
  end
  
  def show_script
    script_record = Ytscript.find(params[:select1])
    @script = CTaskScript.new
    @script.parse(EncodeUtil.change("GB2312", "UTF-8", script_record.content))
    render :partial=>'showscript', :locals=>{:script=>@script}
  end
  
################################################################  
 
###################任务时间管理#################################### 
 def tasktime_manager
    taskid = params[:id] if params[:id]
    session[:task] = Task.find(taskid) if taskid
    @tasktime_pages, @tasktimes = paginate :Yttasktime, :per_page => 20, :conditions=>"taskid=#{session[:task].id}", :order=>"tasktimeid"
 end
 
 def new_tasktime
    @tasktime = Yttasktime.new
    @tasktime.taskid = session[:task].id
 end
 
 def create_tasktime
    @tasktime = Yttasktime.new(params[:tasktime])
    @tasktime.taskid = session[:task].id
    if !@tasktime.begintime || !@tasktime.endtime || !@tasktime.submitbegintime|| !@tasktime.submitendtime
      flash[:error] = '添加任务时间失败'
      render :action => 'new_tasktime'
      return
    end
    
    if @tasktime.save
      flash[:notice] = '添加任务时间成功.'
      redirect_to :action => 'tasktime_manager'
    else
      flash[:error] = '添加任务时间失败.'
      render :action => 'new_tasktime'
    end
 end
 
 def edit_tasktime
  @tasktime = Yttasktime.find(params[:id])
 end
 
 def update_tasktime
  @tasktime = Yttasktime.find(params[:id])
  p params
  if params[:tasktime]['begintime'].size * params[:tasktime]['endtime'].size * params[:tasktime]['submitbegintime'].size * params[:tasktime]['submitendtime'].size == 0
      flash[:error] = '任务时间更新失败'
      render :action => 'edit_tasktime'
      return
  end
    
  if @tasktime.update_attributes(params[:tasktime])
      flash[:notice] = '任务时间更新成功'
      redirect_to :action => 'tasktime_manager'
  else
      flash[:error] = '任务时间更新失败'
      render :action => 'tasktime_manager'
  end
 end
 
 def destroy_tasktime
  Yttasktime.find(params[:id]).destroy
  flash[:notice] = '删除任务时间成功'
  redirect_to :action=>'tasktime_manager'
 end
 
####################任务可见性设置##########################
  def visible_manager
    @taskid = params[:id] if params[:id]
    @task = Task.find(@taskid) if @taskid
    
    #@group_pages, @groups = paginate :YtaplGroup, :per_page => 10
    @groups = YtaplGroup.find(:all)
  end 
  
  def update_visible
    if !params['task']
      Yttaskvisible.delete_all("taskid = #{params['id']}")
    end
    
    @task = Task.find(params['id'])
    if @task.update_attributes(params['task'])
        @task.save
        flash[:notice] = "修改任务可见性成功"
    else
        flash[:error] = "修改任务可见性失败"
    end
    redirect_to :action=>"visible_manager", :id=>@task.id
  end
 
################################################################ 
  def convert_task
    session[:task] = Task.find(params[:id]) if params[:id]
    @converts = YtaplConverttask.find(:all, :conditions=>"taskid=#{session[:task].id}")
  end

  def upload_convert
    stream = params[:file]
    convert = YtaplConverttask.new
    convert.taskid = params[:id]
    convert.name = stream.original_filename[0, stream.original_filename.index(".")]
    convert.content = stream.read
    convert.publishtime = Time.new
    begin
      doc = Document.new(convert.content)
    rescue
      flash[:error] = "发布失败"
      redirect_to :action=>"convert_task", :id=>params[:id]
      return
    end
    convert.save
    flash[:notice] = "发布成功"    
    redirect_to :action=>"convert_task", :id=>params[:id]
  end
  
  def download_convert
    convert = YtaplConverttask.find(params[:id])
    send_data convert.content, :filename=>EncodeUtil.change("GB2312", "UTF-8", convert.name)+".xml"
  end
  
  def destroy_convert
    YtaplConverttask.find(params[:id]).destroy
    flash[:notice] = "删除成功"
    redirect_to :action=>"convert_task", :id=>session[:task].id
  end

################################################################
  #发布任务
  def create
   begin
   	YtLog.info "开始创建任务"
    conn = ActiveRecord::Base.connection
    stream = params[:task]
    helper = XMLHelper.new
    xmlstr = stream.read
    helper.ReadFromString(xmlstr)
    tables = helper.tables
    params = helper.parameters
    dictionFactory = helper.dictionFactory
    script = helper.script    
    conn.begin_db_transaction()
    #先创建任务
    @task = Task.new
    @task.strid = params["task.id"].downcase
    @task.name = params["task.name"]
    @task.version = 1
    @task.datecreated = Time.new
    @task.view = EncodeUtil.change("UTF-8", "GB2312", xmlstr)
    @task.save
    YtLog.info "任务记录保存"
    
    #添加任务时间记录
    now = Time.new
    if params["task.type"] =="年报"
      begintime = now.at_beginning_of_year
      Integer(0).upto(9) do |i|
        endtime = begintime.next_year.yesterday
        submit_begintime = begintime
        submit_endtime = begintime.next_month.next_month
        attention_begintime = begintime
        attention_endtime = attention_begintime.next_month.next_month
        new_tasktime(@task.id, begintime, endtime, submit_begintime, submit_endtime, attention_begintime, attention_endtime)
        
        begintime = begintime.next_year
      end
    elsif params["task.type"] == "周报"
    
    elsif params["task.type"] == "日报"
    
    elsif params["task.type"] == "季报"
      begintime = now.at_beginning_of_year
      1.upto(20) do |i|
        endtime = begintime.months_ago(-3).yesterday
        submit_begintime = begintime.months_ago(-3)
        submit_endtime = begintime.months_ago(-6)        
        attention_begintime = begintime.months_ago(-3)
        attention_endtime = begintime.months_ago(-6)
        new_tasktime(@task.id, begintime, endtime, submit_begintime, submit_endtime, attention_begintime, attention_endtime)
        
        
        begintime = begintime.months_ago(-3)
      end
    elsif params["task.type"] == "旬报"
    
    else                          #按月报处理
      begintime = now.at_beginning_of_month       
      Integer(0).upto(23) do |i|
        endtime = begintime.next_month.yesterday
        submit_begintime = begintime.next_month
        submit_endtime = submit_begintime.next_week.next_week
        attention_begintime =  begintime.next_month
        attention_endtime = attention_begintime.next_week.next_week
      
        new_tasktime(@task.id, begintime, endtime, submit_begintime, submit_endtime, attention_begintime, attention_endtime)
        
        begintime = begintime.next_month
      end
    end

    #建立附件表
    #sql = "create table ytapl_#{@task.strid}_attachment(id int  auto_increment not null, unitid varchar(100), tasktimeid int, name varchar(100), path varchar(200), primary key(id))"
    #conn.execute(sql)    
    conn.create_table "ytapl_#{params["task.id"]}_attachment", :primary_key=>:id do |t|
    	t.column :unitid, :string, :limit=>100, :null=>true
    	t.column :tasktimeid, :integer
    	t.column :name, :string, :limit=>100, :null=>true
    	t.column :path, :string, :limit=>200, :null=>true
    end
    
    #添加表记录
    count = 0;
    for table in tables
      count += 1
  	  YtLog.info table.GetTableID()
      sql = "create table ytapl_#{@task.strid}_#{table.GetTableID().downcase} (unitid varchar(30) ";
      sql += ",tasktimeid int " if count != 1 
      Integer(0).upto(table.GetRowCount()-1) do |row|
        next if table.IsEmptyRow(row)
        
        #添加浮动行表
        if table.IsFloatTemplRow(row)
          floatsql = "create table ytapl_#{@task.strid}_#{table.GetTableID().downcase}_#{table.PhyRowToLogicRow(row+1)} (unitid varchar(30), tasktimeid int, float_id int not null auto_increment primary key ";
          Integer(0).upto(table.GetColumnCount()-1) do |col|  
            floatsql += get_field_sql(table, row, col)
          end        
          floatsql += ")"
          #floatsql += ", primary key (unitid, tasktimeid, float_id))"
          conn.execute(floatsql)          
        end        
        
        Integer(0).upto(table.GetColumnCount()-1) do |col|  
          next if !table.GetCell(row, col).IsEffective()          
          sql += get_field_sql(table, row, col)          
        end
      end
      
      #对每张报表开始新建表
      sql += ",p_parent varchar(100), display int, " if count == 1
      if count==1
        sql += "primary key (unitid))" 
      else
        sql += ",primary key (unitid,tasktimeid))" 
      end
      begin
        conn.execute(sql)
      rescue Exception => error
        YtLog.info error
      end
    end
    
    conn.commit_db_transaction
    
    #设置所有组都可见
    groups = YtaplGroup.find(:all)
    for group in groups 
      visible = Yttaskvisible.new
      visible.groupid = group.id
      visible.taskid = @task.id
      visible.save
    end   
    
    
    flash[:notice] = '创建任务成功'
    redirect_to :action => "index"
    
    #TaskMeta.LoadAllTask
    TaskMeta.LoadTask(@task.id)
   rescue Exception=>err
   	p err.to_s[0, 200]
    flash[:error] = '创建任务失败'
    redirect_to :action => "index"
    conn.rollback_db_transaction
   end
  end
  
  #删除任务
  def destroy
    task = Task.find(params[:id])
    meta = $TaskDesc[task.strid]
    
    conn = ActiveRecord::Base.connection
    
    for table in meta.helper.tables
      Integer(0).upto(table.GetRowCount()-1) do |row|
        if table.IsFloatTemplRow(row)
          conn.drop_table "ytapl_#{task.strid}_#{table.GetTableID().downcase}_#{table.PhyRowToLogicRow(row+1)}"
          #conn.execute("drop table if exists ytapl_#{task.strid}_#{table.GetTableID().downcase}_#{table.PhyRowToLogicRow(row+1)} ")
        end
      end
      conn.drop_table "ytapl_#{task.strid}_#{table.GetTableID().downcase}"
      #conn.execute("drop table if exists ytapl_#{task.strid}_#{table.GetTableID().downcase} ")
    end
    
    conn.drop_table "ytapl_#{task.strid}_attachment"
    #conn.execute("drop table if exists ytapl_#{task.strid}_attachment ")
    
    Yttasktime.delete_all("taskid = #{task.id}")
    taskstr = task.strid
    Yttaskvisible.delete_all("taskid=#{task.id}")
    
    #task.destroy
    Task.delete(params[:id])
    
    flash[:notice] = '删除任务成功'
    $TaskDesc.delete(task.strid)
    
    redirect_to :action => "index"
  end
  
  #下载任务
  def download_task
    task = Task.find(params[:id])
    file = File.new 'tmp/task.xml', 'w'
    file.write EncodeUtil.change('GB2312', 'UTF-8', task.view)
    file.close
    send_file 'tmp/task.xml', :filename => task.strid + ".xml"
  end
  
  def hide_task
    @task = Task.find(params['id'])
    if @task
      @task.reserved1 = '1'
      @task.save
      flash[:notice] = "封存#{@task.name}成功"
    else
      flash[:notice] = "封存#{@task.name}失败"
    end
    redirect_to :action=>'publish_task'
  end
  
  def unhide_task
    @task = Task.find(params['id'])
    if @task
      @task.reserved1 = '0'
      @task.save
      flash[:notice] = "解存#{@task.name}成功"
    else
      flash[:notice] = "解存#{@task.name}失败"
    end
    redirect_to :action=>'publish_task'
  end
  
  #调整任务顺序
  def order
    orders = params[:tasklist]
    1.upto(orders.size()) do |i|
      Task.update_all("position = #{i}", "taskid = #{orders[i-1]}")
    end
    @tasks = Task.find_by_sql("select taskid as id, taskid, strid,datecreated,memo, name,reserved1 from ytapl_tasks order by position")
    render :partial=>'tasklist'
  end
  
  #调整模板顺序
  def template_order
    orders = params[:templateslist]
    1.upto(orders.size()) do |i|
      Ytreporttemplate.update_all("reserved1 = #{i}", "templateid = #{orders[i-1]}")
    end
    @templates = Ytreporttemplate.find(:all, :conditions=>"taskid = '#{session[:task].strid}'", :order=>"reserved1")
    render :partial=>'templatelist'
  end

private
  def new_tasktime(taskid, begintime, endtime, submit_begintime, submit_endtime, attention_begintime, attention_endtime)
        tasktime = Yttasktime.new
        tasktime.taskid = taskid
        tasktime.begintime = begintime
        tasktime.endtime = endtime
        tasktime.submitbegintime = submit_begintime
        tasktime.submitendtime = submit_endtime
        tasktime.attentionbegintime = attention_begintime
        tasktime.attentionendtime = attention_endtime
        
        tasktime.save
  end
  
  def get_field_sql(table, row, col)
    sql = ""
    cell = table.GetCell(row, col)
    return sql if table.GetCellDBFieldName(row, col).strip.size == 0
    
    if cell.GetDataType() == 1 #numeric
       sql += ",#{table.GetCellDBFieldName(row, col)} decimal(14, #{cell.GetDecimal()})"
    elsif cell.GetDataType() == 3 #date
       sql += ",#{table.GetCellDBFieldName(row, col)} datetime "
    else                          #text
      if cell.IsCheckWidth()
        sql += ",#{table.GetCellDBFieldName(row, col)} varchar(#{cell.GetTextWidth})"
      else
        sql += ",#{table.GetCellDBFieldName(row, col)} varchar(200)"
      end            
    end
  end
end
