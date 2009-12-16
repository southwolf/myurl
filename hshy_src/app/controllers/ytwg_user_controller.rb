class YtwgUserController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def find
    condition = "1=1 "
    condition += " and truename like '%#{params[:name]}%'"if params[:name].size > 0
    condition += " and department_id = #{params[:department]}" if params[:department].size > 0
    @ytwg_users = YtwgUser.paginate :conditions=>condition, :order => params[:order] ,:per_page => 2000, :page => params[:page]
    @return = true
    render :action=>'list_detail'
  end
  
  def list   
    if params[:id] != "-1"
      conditions = []
      conditions << "1=1"
      conditions << "department_id = #{params[:id]}" if params[:id]
      @ytwg_users = YtwgUser.paginate :order => params[:order] ,:per_page => 20, 
        :page => params[:page], :conditions=>conditions.join(' and ')
    else
      @ytwg_users = YtwgUser.paginate :order => params[:order] ,:per_page => 20, 
        :page => params[:page], :conditions=>"department_id is null"
    end
  end
  
  def list_detail
    conditions = []
    conditions << "1=1"
    conditions << "department_id = #{params[:id]}" if params[:id]
    @ytwg_users = YtwgUser.paginate :order => "position" ,:per_page => 20, 
      :page => params[:page], :conditions=>conditions.join(' and ')
    render :layout=>"notoolbar_app"
  end
  
  def list_all
    @ytwg_users = YtwgUser.find(:all, :conditions=>"name <> 'admin' and (resign<>1 or resign is null)")
  end

  def show
    @ytwg_user = YtwgUser.find(params[:id])
  end

  def new
    @ytwg_user = YtwgUser.new
  end

  def create
    @ytwg_user = YtwgUser.new(params[:ytwg_user])
    digest = Digest::MD5.new
    digest << @ytwg_user.password
    @ytwg_user.password = digest.hexdigest
    if @ytwg_user.save
      flash[:notice] = '创建用户成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_user = YtwgUser.find(params[:id])
    render :layout=>"notoolbar_app"
  end

  def update
    @ytwg_user = YtwgUser.find(params[:id])
    pass_changed = false
    if @ytwg_user.password != params[:ytwg_user][:password]
      pass_changed = true
    end
    if @ytwg_user.update_attributes(params[:ytwg_user])
      if pass_changed
        digest = Digest::MD5.new
        digest << @ytwg_user.password
        @ytwg_user.password = digest.hexdigest
        @ytwg_user.save
      end
      #flash[:notice] = '修改用户成功'
      redirect_to :action => 'list_detail', :id => @ytwg_user.department_id
    else
      render :action => 'edit'
    end
  end
  
  def update_profile
    @ytwg_user = YtwgUser.find(params[:id])
    pass_changed = false
    if @ytwg_user.password != params[:ytwg_user][:password]
      pass_changed = true
    end
    if @ytwg_user.update_attributes(params[:ytwg_user])
      if pass_changed
        digest = Digest::MD5.new
        digest << @ytwg_user.password
        @ytwg_user.password = digest.hexdigest
        @ytwg_user.save
      end
      render :text=>"修改成功"
    else
      render :action => 'editprofile', :id=>@ytwg_user
    end
  end

  def destroy
    user = YtwgUser.find(params[:id])
    redirect_to :action => 'list_detail', :id=> user.department_id
    user.destroy
  end
  
  #编辑个人资料
  def editprofile
    @ytwg_user = YtwgUser.find(session[:user].id)
    render :layout=>"notoolbar_app"
  end
  
  def resign
     @ytwg_user = YtwgUser.find(params[:id])
     @ytwg_user.resign = 1
     @ytwg_user.save
     redirect_to :action=>"list_detail", :id=>@ytwg_user.id
  end
  
  def reorder
    @nodes = YtwgUser.find(:all, :conditions=>"department_id = #{params[:id]}", :order=>"position")
    render :layout=>"notoolbar_app"
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = YtwgUser.find(node)
      child.position = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end
end
