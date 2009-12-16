#私人文档共享
class FileshareController < ApplicationController
  def index
    @files = Fileshare.find(:all, :conditions=>"userid=#{session[:user].id}")
    @users = YtwgUser.find(:all)
  end
  
  def upload_file
    for user in params[:user]
      file = Fileshare.new(params[:sharefile])
      file.sender = session[:user].truename
      file.uploadtime = Time.new
      file.userid = user
      file.save
    end
    flash[:notice] = "发送文件成功"
    redirect_to :action=>'index'
  end
  
  def download_file
    file = Fileshare.find(params[:id])
    send_file file.path
  end
  
  def delete_file
    Fileshare.find(params[:id]).destroy
    flash[:notice] = "删除文件成功"
    redirect_to :action=>'index'
  end
end
