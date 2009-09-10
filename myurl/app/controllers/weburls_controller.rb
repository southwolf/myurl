class WeburlsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @weburls_pages, @weburls = paginate :weburls, :per_page => 10
  end

  def show
    @weburls = Weburls.find(params[:id])
  end

  def new
    @weburls = Weburls.new
  end

  def create
    @weburl = Weburl.new(params[:weburl])
    @weburl.user_id = session[:user].id
    url = Weburl.find(:first, :conditions=>"user_id = #{session[:user].id} and address='#{@weburl.address}'")
    if url    #是修改
      if url.update_attributes(params[:weburl])
        flash[:notice] = "修改收藏成功"
        redirect_to :controller=>"main", :action => 'myurl', :cata=>@weburl.catalog_id
        return
      end
    end
    
    if !@weburl.address.size || @weburl.address.size == 0
      flash[:notice] = '请输入网址'
      redirect_to :controller=>"main", :action => 'myurl', :cata=>@weburl.catalog_id
      return
    end
    
    r = Recommand.find(:first, :conditions=>"address='#{@weburl.address}'")
    if r
      @weburl.recommand_id = r.id
    end
    if @weburl.save
      flash[:notice] = '成功收藏了一个网站！'
      
      recent = Recent.new
      recent.user_id = session[:user].id
      recent.kind = 1
      recent.site_id = @weburl.id
      recent.save
      
      #expire_page :controller=>"main", :action=>"index"
      
      redirect_to :controller=>"main", :action => 'myurl', :cata=>@weburl.catalog_id
    else
      render :action => 'new'
    end
  end

  def edit
    @weburls = Weburls.find(params[:id])
  end

  def update
    @weburls = Weburls.find(params[:id])
    if @weburls.update_attributes(params[:weburls])
      flash[:notice] = 'Weburls was successfully updated.'
      redirect_to :action => 'show', :id => @weburls
    else
      render :action => 'edit'
    end
  end

  def destroy
    url = Weburls.find(params[:id])
    url.destroy
    flash[:notice] = "成功删除一个收藏"
    redirect_to :controller=>"main", :action => 'myurl', :cata=>url.catalog_id
  end
end
