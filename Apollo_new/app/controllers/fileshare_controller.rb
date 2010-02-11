#私人文档共享
class FileshareController < ApplicationController
  layout "main"
  def index
    @files = YtaplFileshare.find(:all, :conditions=>"userid=#{session[:user].id}")
    
    meta = $TaskDesc[session[:task].strid]
    UnitFMTableData.set_table_name("ytapl_#{session[:task].strid}_#{meta.fmtable}")
    UnitFMTableData.reset_column_information
    
    units = Array.new
    #本级
    for group in session[:user].groups
      permissions = Ytunitpermissions.find(:all, :conditions=>"groupid = #{group.id} and taskid=#{session[:task].id}")
      for permission in permissions
        unit = UnitFMTableData.find(permission.unitid) rescue nil
        units << unit if unit
      end
    end
    #下级
    for unit in units
      for child in unit.children
        units << child
      end
    end
    
    #直系上级
    for unit in units
      units<<unit.parent if unit.parent
    end
    unitids = Array.new
    for unit in units
      unitids << "'" + unit.unitid + "'"
    end
    ids = unitids.join(',')
    ids = "\'\'" if ids.size == 0
    #找出所有组
    permit_groups = Ytunitpermissions.find(:all, :conditions=>"taskid = #{session[:task].id} and unitid in (#{ids})")
    @users = Array.new
    for permit in permit_groups
      group = YtaplGroup.find(permit.groupid) rescue nil
      next if !group
      for user in group.users
        @users << user
      end
    end
    @users.uniq!
    @users.sort!
  end
  
  def upload_file
    for user in params[:user]
      file = YtaplFileshare.new(params[:sharefile])
      file.sender = session[:user].truename
      file.uploadtime = Time.new
      file.userid = user
      file.save
    end
    flash[:notice] = "发送文件成功"
    redirect_to :action=>'index'
  end
  
  def download_file
    file = YtaplFileshare.find(params[:id])
    send_file file.path
  end
  
  def delete_file
    YtaplFileshare.find(params[:id]).destroy
    flash[:notice] = "删除文件成功"
    redirect_to :action=>'index'
  end
end
