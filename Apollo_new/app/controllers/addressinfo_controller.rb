class AddressinfoController < ApplicationController
  layout "subsubwindow"
  
  def index
    session[:task] = Task.find(params[:id]) if params[:id]
  end
  
  def edit
    @meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{@meta.fmtable}".downcase)
    @unit = UnitFMTableData.find(params[:id])
    infos = Ytaddressinfo.find(:all, :conditions=>"unitid='#{@unit.unitid}'")
    if infos.size == 0
      render :action=>"new"
    elsif
      @ytaddressinfo = infos[0]
      render :action=>"edit"
    end
  end
  
  def list
    @info_pages, @infos = paginate :Ytaddressinfo, :per_page => 10
    @meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{@meta.fmtable.downcase}")
  end
  
  def create
    @info = Ytaddressinfo.new(params[:ytaddressinfo])
    @info.unitid = params[:unitID]
    @info.save
    flash[:notice] = '添加催报信息成功'
    redirect_to :action => "edit", :id => params[:unitID]
  end
  
  def update
    @ytaddressinfo = Ytaddressinfo.find(params[:id])
    if @ytaddressinfo.update_attributes(@params[:ytaddressinfo])
      flash[:notice] = '修改催报信息成功'
      redirect_to :action => 'edit', :id => params[:id]
    else
      flash[:notice] = '修改催报信息失败'
      redirect_to :action => 'edit', :id => params[:id]
    end
  end
  
  def urge
    info = Ytaddressinfo.find(params[:id]) rescue nil
    Mail.deliver_urge(info) if info
    flash[:notice] = '催报邮件发送完毕'
    redirect_to :action=>'list'
  end
  
  def transfer_urge
    info = Ytaddressinfo.find(params[:id]) rescue nil
    Mail.deliver_urge(info) if info
    render :layout=>'popup'
  end
end
