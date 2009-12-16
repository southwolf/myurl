class NoticeController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@ytwg_news_pages, @ytwg_news = paginate :notice, :per_page => 20, :order=>"id desc"
     @ytwg_news = Notice.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @ytwg_news = Notice.find(params[:id])
    @ytwg_news.users << session[:user] rescue nil
  end

  def new
    @ytwg_news = Notice.new
  end

  def create
    @ytwg_news = Notice.new(params[:ytwg_news])
    @ytwg_news.publish_time = Time.new
    @ytwg_news.user_id = session[:user].id
    
    if !@ytwg_news.title || @ytwg_news.title.size == 0
      flash[:notice] = '请填写标题'
      render :action=>'new'
      return
    end
    
    if @ytwg_news.save
      flash[:notice] = '添加通知成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_news = Notice.find(params[:id])
  end

  def update
    @ytwg_news = Notice.find(params[:id])
    if @ytwg_news.update_attributes(params[:ytwg_news])
      flash[:notice] = '修改通知成功'
      redirect_to :action => 'list', :id => @ytwg_news
    else
      render :action => 'edit'
    end
  end

  def destroy
    Notice.find(params[:id]).destroy
    redirect_to :action => 'list'
    flash[:notice] = '删除通知成功'
  end
  
  def read
    @notice = Notice.find(params[:id])
  end
end
