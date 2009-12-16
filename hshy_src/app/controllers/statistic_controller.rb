class StatisticController < ApplicationController
  def index
    if !checkright("工作量统计")
      render :text => "对不起，您没有工作量统计权限"
      return
    end
  end
  
  def query
    condition = "1=1 "
    
    condition += "and logtype = #{params[:logtype]}" if params[:logtype] != ""
    
    condition += " and person_id = #{params[:person_id]}" if params[:person_id] != ""
    
    condition += " and project_id = #{params[:project_id]}" if params[:project_id] != ""
    
    condition += " and department_id = #{params[:department_id]}" if params[:department_id] != ""
    
    condition += " and uptime > '#{params[:begintime]}'" if params[:begintime] != ""
    
    @works = Work.find(:all, :conditions => condition, :order=> 'id desc')

  end
  
  def remark
    work = Work.find(params[:id])
    work.remark = session[:user].truename + ":" + EncodeUtil.change("GB2312", "UTF-8", params[:value])
    work.save
    render :text=>work.remark
  end
end