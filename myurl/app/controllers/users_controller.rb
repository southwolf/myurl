class UsersController < ApplicationController
  before_filter :admin_required, :only=>["list"]
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @user_pages, @users = paginate :users, :per_page => 10
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new 
  end

  def create
    if User.find(:first, :conditions=>"name = '#{params[:user][:name]}'")
      flash[:notice] = "这个账号已被注册,请换一个名字!"
      render :action => 'new'
      return
    end
    
    if simple_captcha_valid?      
      @user = User.new(params[:user])
      digest = Digest::MD5.new
      digest << @user.password
      @user.password = digest.hexdigest
      if @user.save
        flash[:notice] = '注册成功'
        session[:user] = @user
        cookies[:name] = {:value=>@user.name, :expires=>300.days.from_now}
        recent = Recent.new
        recent.user_id = @user.id
        recent.kind = 3
        recent.desc = "成为网站新用户"
        recent.save
        expire_page :controller=>"main", :action=>"index"
        redirect_to :controller=>"main", :action => 'index'
      else
        render :action => 'new'
      end
    else     
       flash[:notice] = '对不起，您输入的验证码错误'
       render :action => 'new' 
    end     
    
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def register
    @user = User.new 
    render :action=>"new"
  end
  
  def logout
    session[:user] = nil
    
    cookies[:name] = nil
      
    redirect_to :controller=>"main", :action=>"index"
  end
  
  def change_pic
    render :layout=>false
  end
  
  def check_unique
    user = User.find(:first, :conditions=>"name='#{params[:name]}'")
    if user
      render :text=>"<font color='red'>真不巧，这个登录名被别人使用了!</font>"
    else
      render :text=>"<font color='red'>这个登录名还没被注册，您可以使用!</font>"
    end
  end
  
  def check_unique_nick
    user = User.find(:first, :conditions=>"nickname='#{params[:name]}'")
    if user
      render :text=>"<font color='red'>真不巧，这个昵称被别人使用了!</font>"
    else
      render :text=>"<font color='red'>这个昵称还没被注册，您可以使用!</font>"
    end
  end
  
  def remote_check
    password = (Digest::MD5.new << params[:password]).hexdigest
    user = User.find(:first, :conditions=>"name='#{params[:name].to_utf8}' and password='#{password}'")
    if user
      render :text=> user.id.to_s
    else
      render :text=>"fail"
    end
  end
end
