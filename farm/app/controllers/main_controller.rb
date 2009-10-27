require 'kaixinfarm'
class MainController < ApplicationController
  before_filter :login_required, :only=>['mygames']
  
  def logout
    session[:user] = nil
    flash[:notice] = "注销成功"
    redirect_to :action=>'index'
  end
  
  def trylogin
    params[:name] = params[:name].delete("\"'<>") if params[:name]
    if !params[:name] ||params[:name].size == 0
      flash[:notice] = "请输入用户名"
      redirect_to :controller=>"main", :action=>'login'
      return
    end
    
    if !params[:password] ||params[:password].size == 0
      flash[:notice] = "请输入密码"
      redirect_to :controller=>"main", :action=>'login'
      return
    end
    
    digest = Digest::MD5.new
    digest << params[:password]
    password = digest.hexdigest
    
    admin = User.find(:first, :conditions=>"name='#{params[:name]}'")
    if !admin 
      flash[:notice] = "对不起，没有这个用户" + params[:name]
      redirect_to :controller=>"main", :action=>'login'
      return
    end
    
    admin = User.find(:first, :conditions=>"name='#{params[:name]}' and password='#{password}'")
    if !admin
      flash[:notice] = "对不起，密码错误"
      redirect_to :controller=>"main", :action=>'login'
    else
      session[:user] = admin
      flash[:notice] = "欢迎您回来:" + admin.nickname

      redirect_to :controller=>"main", :action=>'mygames'
    end
  end
  
  def kaixinfarm
    @kaixin_user = Kaixinuser.find(:first, :conditions=>"name='#{params[:name]}'")
    if !@kaixin_user
      @kaixin_user = Kaixinuser.new
      @kaixin_user.name = params[:name]
      @kaixin_user.password = params[:password]
      @kaixin_user.save
      session[:user].kaixinuser_id = @kaixin_user.id
      session[:user].save
      session[:user].kaixinuser = @kaixin_user
    else
      @kaixin_user.password = params[:password]
      @kaixin_user.save
      session[:user].kaixinuser_id = @kaixin_user.id
      session[:user].save
    end
    
    @farm = $KAIXIN_FARM_CLIENT[session[:user].id] || KaixinFarm.new
    if @farm.login(params[:name], params[:password])
      @friends = @farm.get_friends
      session[:user].kaixinuser.friendids   = @kaixin_user.friendids = @friends.collect{|f| f[0]}.join(',')
      session[:user].kaixinuser.friendnames = @kaixin_user.friendnames = @friends.collect{|f| f[1]}.join(',')
      @kaixin_user.code = @farm.user_id
      @kaixin_user.save
      @myconf = @farm.get_farm_conf(@farm.user_id)
      @mydoc =  Hpricot(@myconf)
      flash[:notice] = '登陆开心网成功'
      $KAIXIN_FARM_CLIENT[session[:user].id] = @farm
    else
      flash[:notice] = '登陆开心网失败'
      render :action=>"mygames"
      return
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
    end
  end
  
  def friendfarm
    @kaixin_user = Kaixinuser.find(params[:kaixinuser_id])
    if params[:id]
      @conf = $KAIXIN_FARM_CLIENT[session[:user].id].get_farm_conf(params[:id])
      @doc =  Hpricot(@conf)
      dumpfile(@conf, 'd:\cc.xml')
    end
    render :partial=>"friendfarm", :layout=>false
  end
  
  def kaixinfarm_begin
    $KAIXIN_FARM_CLIENT[session[:user].id].exam_farm
    session[:user].kaixinuser.executing = 1
    session[:user].kaixinuser.save
    render :text=>"<p style='margin:20px'><h2>您的开心农场已经成功交给“开心保姆”托管，你可以出去开心了！</h2></p>"
  end
  
  def kaixinfarm_stop
    session[:user].kaixinuser.executing = 0
    session[:user].kaixinuser.save
    Kaixintask.update_all "stopflag = 1", "kaixinuserid = #{session[:user].kaixinuser.code}"
    render :text=>"<p style='margin:20px'><h2>您的开心农场托管已经停止</h2></p>"
  end
  
  def kaixinfarm_to_execute
    code = session[:user].kaixinuser.code
    @tasks = Kaixintask.find(:all, :conditions=>"kaixinuserid = #{code} and finished = 0 and stopflag = 0")
    render :layout=>false
  end
  
  def kaixinfarm_that_finished
    code = session[:user].kaixinuser.code
    @tasks = Kaixintask.find(:all, :conditions=>"kaixinuserid = #{code} and finished = 1")
    render :layout=>false
  end

  def test
    s = Kaixinscheduler.new
    s.occurtime = Time.new
    s.save
    render :text=>"just a joke"
  end
  
  def index2
    render :layout=>false
  end
end
