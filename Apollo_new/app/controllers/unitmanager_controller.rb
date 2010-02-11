class UnitmanagerController < ApplicationController
  layout "subwindow"
  def index
    if params[:id]
      session[:task] = Task.find(params[:id])
    end
  end
  
  def edit
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}".downcase)
    @unit = UnitFMTableData.find(:all, :conditions => "unitid='#{params[:id]}'")[0]
    render :action => "edit", :layout =>false
  end
  
  def update
    p params
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}".downcase)
    UnitFMTableData.set_primary_key :unitid
    UnitFMTableData.reset_column_information    
    
    @unit = UnitFMTableData.find(params[:id])
    @unit.Bak
    begin      
      @unit['unitid'] = params[:unit]["#{meta.unitcode}"] + params[:unit]["#{meta.reporttype}"]
      @unit.save      
      @unit.update_attributes(params[:unit])
      flash[:notice] = '单位信息修改成功'
    rescue
      flash[:error] = '单位信息修改失败'
    end
    @unit = UnitFMTableData.new
    render :action => 'index'
  end
  
  def new
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}".downcase)    
    @unit = UnitFMTableData.new
    @unit.BBLX = "9"
    render :action => 'new', :layout=>false
  end
  
  def create
    meta = $TaskDesc[session[:task].strid]

    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}".downcase)
    @unit = UnitFMTableData.new(params[:unit])
    @unit["unitid"] = @unit["#{meta.unitcode}"] + @unit["#{meta.reporttype}"]
    
    begin
      if UnitFMTableData.find(@unit["unitid"])
        flash[:error] = '单位代码重复，创建失败'
        render :action =>'index'
        return
      end
    rescue
    end
    @unit.save
    
    @unit = nil
    
    flash[:notice] = '单位创建成功'
    render :action =>'index'
  end
  
  def delete
    meta = $TaskDesc[session[:task].strid]
    unitid = params[:id]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}".downcase)
    UnitFMTableData.delete(unitid)
    
    params[:id] = nil
    flash[:notice] = '单位删除成功'
    redirect_to :action => 'index'
  end
  
  def selectunit
    @doAfterDone = params[:doAfterDone]
    render :layout=>false
  end
  
  def selectbylist
    @meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{@meta.fmtable}".downcase)
    @units = UnitFMTableData.find(:all)
    render :layout=>false
  end
  
  def selectbytree
    render :layout=>false
  end
  
  #复制单位
  def copy_unit
    desTask = Task.find(params[:id])
    desMeta = $TaskDesc[desTask.strid]
    
    srcTask = Task.find(params[:from_task])
    srcMeta = $TaskDesc[srcTask.strid]
    UnitFMTableData.set_table_name("ytapl_#{srcTask.strid}_#{srcMeta.fmtable}".downcase)
    UnitFMTableData.reset_column_information() 
    srcUnits = UnitFMTableData.find(:all)
    
    UnitFMTableData.set_table_name("ytapl_#{desTask.strid}_#{desMeta.fmtable}".downcase)
    UnitFMTableData.reset_column_information() 
    UnitFMTableData.delete_all if params[:delete_pre] == '1'
    index = 0
    for srcUnit in srcUnits
      desUnit = UnitFMTableData.new()
      desUnit['unitid'] = srcUnit['unitid']
      desUnit[desMeta.unitcode] = srcUnit[srcMeta.unitcode]
      desUnit[desMeta.unitname] = srcUnit[srcMeta.unitname]
      desUnit[desMeta.reporttype] = srcUnit[srcMeta.reporttype]
      desUnit[desMeta.parentunit] = srcUnit[srcMeta.parentunit]
      desUnit[desMeta.headquater] = srcUnit[srcMeta.headquater]
      desUnit.p_parent = srcUnit.p_parent
      desUnit["display"] = srcUnit["display"]
      begin
        desUnit.save
        index += 1
      rescue
      end
    end
    
    #复制权限
    srcPermissions = Ytunitpermissions.find(:all, :conditions=>"taskid=#{srcTask.id}")
    for srcPermission in srcPermissions
      desPermission = Ytunitpermissions.new(srcPermission.attributes)
      desPermission.taskid = desTask.id
      desPermission.save
    end
    
    
    flash[:notice] = "成功复制了#{index}家单位"
    redirect_to :action=>'index', :id=>params[:id]
  end
  
  #保存方案
  def save_schema
    schema = YtaplUnitschema.new
    schema.taskid = session[:task].id
    schema.name = params[:schema_name]
    schema.content = params[:unitids]
    schema.save
    render :text => "保存方案成功"
  end
  
  def delete_schema
    YtaplUnitschema.delete_all("taskid = #{session[:task].id} and content = '#{params[:id]}'")
    redirect_to :action=>'index'
  end
end
