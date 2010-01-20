require 'digest/md5'
class LoginController < ApplicationController
  def index
    session[:user] = nil
    render :action=>'index', :layout=>false
  end
  
  #覆盖父类的login，取消登陆验证
  def check_user

  end
  
  def hehe_hehe
    $mac_ip ||= Hash.new 
    
    if !params[:mac] || !params[:identify]
      render :text=>"客户端已升级，请更新"
      return
    end
    
    if $mac_ip[params[:mac]+request.env_table["REMOTE_ADDR"]] != params[:identify]
      render :text=>"系统发现您正在进行黑客行为，后台已添加日志，请用正常方式登录"
      write_log("发现黑客行为")
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
      flash[:notice] = "用户名不存在"
      write_log("登陆用户名#{account}不存在")
      redirect_to :action=>'hehe_hehe' 
      return
    end
    
    digest = Digest::MD5.new
    digest << password
    dbpassword = digest.hexdigest
    user = YtwgUser.find(:all, :conditions=>"name = '#{account}' and password='#{dbpassword}'")
    if user.length == 0
      flash[:notice] = '密码错误'
      write_log("#{account}:登陆密码错误")
      redirect_to :action=>'hehe_hehe' 
    else
      if user[0].resign == 1
        flash[:notice] = '对不起，您已离职！'
        redirect_to :action=>'hehe_hehe' 
        return
      end
      user[0].last_login_time = Time.new
      user[0].save
      session[:user] = user[0]
      session[:pwd] = params[:password]
      flash[:notice] = '欢迎登陆:' + session[:user].truename.to_s || session[:user].name.to_s
      write_log("成功登陆系统")
      
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
