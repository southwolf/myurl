require 'digest/md5'
class LoginController < ApplicationController
  def index
    session[:user] = nil
    render :action=>'index', :layout=>false
  end
  
  #���Ǹ����login��ȡ����½��֤
  def check_user

  end
  
  def hehe_hehe
    $mac_ip ||= Hash.new 
    
    if !params[:mac] || !params[:identify]
      render :text=>"�ͻ����������������"
      return
    end
    
    if $mac_ip[params[:mac]+request.env_table["REMOTE_ADDR"]] != params[:identify]
      render :text=>"ϵͳ���������ڽ��кڿ���Ϊ����̨�������־������������ʽ��¼"
      write_log("���ֺڿ���Ϊ")
      return
    end
    
    @config = YtwgSystem.find(:all, :limit=>1)[0]
    @config = YtwgSystem.new if !@config
    render :layout=>false
  end
  
  def entry
    @config = YtwgSystem.find(:all, :limit=>1)[0]
    @config = YtwgSystem.new if !@config
    render :action=>"hehe_hehe"
  end
  
  def identify
    $mac_ip ||= Hash.new 
    
    if !params[:mac] || params[:mac].size == 0
      render :text=>"failed"
      return
    end
    
    digest = Digest::MD5.new
    digest << params[:mac] + " haha " + request.env_table["REMOTE_ADDR"]
    dbpassword = digest.hexdigest
    
    $mac_ip[params[:mac]+request.env_table["REMOTE_ADDR"]] = dbpassword
    
    render :text=> dbpassword
  end
  
  def trylogin
    account = params[:account].strip
    password = params[:password]
    
    if YtwgUser.find(:all, :conditions=>"name = '#{account}'").size == 0
      flash[:notice] = "�û���������"
      write_log("��½�û���#{account}������")
      redirect_to :action=>'hehe_hehe' 
      return
    end
    
    digest = Digest::MD5.new
    digest << password
    dbpassword = digest.hexdigest
    user = YtwgUser.find(:all, :conditions=>"name = '#{account}' and password='#{dbpassword}'")
    if user.length == 0
      flash[:notice] = '�������'
      write_log("#{account}:��½�������")
      redirect_to :action=>'hehe_hehe' 
    else
      if user[0].resign == 1
        flash[:notice] = '�Բ���������ְ��'
        redirect_to :action=>'hehe_hehe' 
        return
      end
      user[0].last_login_time = Time.new
      user[0].save
      session[:user] = user[0]
      session[:pwd] = params[:password]
      flash[:notice] = '��ӭ��½:' + session[:user].truename.to_s || session[:user].name.to_s
      write_log("�ɹ���½ϵͳ")
      
      begin
        info = YtwgSystem.find_first()
        info.visitedtimes = info.visitedtimes + 1
        info.save
      rescue
      
      end
      redirect_to :controller =>'main', :action=>'index' 
    end
  end
end
