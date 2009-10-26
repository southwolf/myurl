
class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  # 
  protect_from_forgery :except => [:check, :checknick, :check2]

  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    if User.find(:first, :conditions=>"name='#{params[:user][:name]}'")
      flash[:notice] = "此账号已被注册"
      redirect_to :action=>"register", :controller=>"main"
      return
    end
    
    if User.find(:first, :conditions=>"name='#{params[:user][:name]}'")
      flash[:notice] = "此昵称已被占用"
      redirect_to :action=>"register", :controller=>"main"
      return
    end
    
    if params[:password1] != params[:password2]
      flash[:notice] = "密码和密码确认不一致"
      render :action=>"new", :layout=>"main"
      return
    end    
    
   
    @user = User.new(params[:user])
    for c in %w(_ < > [ ])
      if @user.nickname.index(c) 
        flash[:notice] = "注册失败，名称包含非法字符"
        render :action=>"new", :layout=>"main"
        return
      end
    end
    
    digest = Digest::MD5.new
    digest << params[:password1]
    @user.password = digest.hexdigest

    respond_to do |format|
      if @user.save
        session[:user] = @user
        flash[:notice] = '注册成功！'
        redirect_to :controller=>"main", :action => 'index'
        return
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  #确认账号是否可用
  def check    
    if !params[:email] || params[:email].size == 0
      render :text=>"<img src='/images/cancel.png'>"+"账号名称必填"
      return
    end
    
    @users = User.find(:all, :conditions=>"name='#{params[:email]}'")
    render :layout=>false
  end
  
  def checknick
    p params
    if !params[:nickname] || params[:nickname].size == 0
      render :text=>"请填写昵称"
      return 
    end
    if User.find(:first, :conditions=>"nickname='#{params[:nickname]}'")
      render :text=>"<img src='/images/cancel.png'>昵称已被注册"
    else
      render :text=>"<img src='/images/accept.png'>昵称可用"
    end
  end
  
  
end
