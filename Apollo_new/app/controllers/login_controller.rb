require 'digest/md5'
class LoginController < ApplicationController
  def index
    session[:user] = nil
    render :action=>'index', :layout=>false
  end
  
  #覆盖父类的login，取消登陆验证
  def login
  
  end
  
  def trylogin
    account = params[:account].strip
    password = params[:password]
    
    if YtaplUser.find(:all, :conditions=>"name = '#{account}'").size == 0
      flash[:notice] = "用户名不存在"
      SecurityLog(4, "登陆用户名#{account}不存在")
      redirect_to :action=>'index' 
      return
    end
    
    digest = Digest::MD5.new
    digest << password
    dbpassword = digest.hexdigest
    user = YtaplUser.find(:all, :conditions=>"name = '#{account}' and password='#{dbpassword}'")
    if user.length == 0
      flash[:notice] = '密码错误'
      SecurityLog(4, "登陆密码错误")
      redirect_to :action=>'index' 
    else
      session[:user] = user[0]
      session[:pwd] = params[:password]
      flash[:notice] = '欢迎登陆:' + session[:user].truename.to_s || session[:user].name.to_s
      SecurityLog(3, "成功登陆系统")
      
      begin
        info = YtaplSystem.find_first()
        info.visitedtimes = info.visitedtimes + 1
        info.save
      rescue
      
      end
      redirect_to :controller =>'main', :action=>'index' 
    end
  end
end
