#˽���ĵ�����
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
    flash[:notice] = "�����ļ��ɹ�"
    redirect_to :action=>'index'
  end
  
  def download_file
    file = Fileshare.find(params[:id])
    send_file file.path
  end
  
  def delete_file
    Fileshare.find(params[:id]).destroy
    flash[:notice] = "ɾ���ļ��ɹ�"
    redirect_to :action=>'index'
  end
end
