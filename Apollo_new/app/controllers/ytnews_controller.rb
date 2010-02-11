class YtnewsController < ApplicationController
  layout "main"
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }  
  def list
    @ytnews_pages, @ytnews = paginate :ytnews, :per_page => 10, :order=>"id desc"
  end

  def show
    @ytnews = Ytnews.find(params[:id])
    save_browse(@ytnews)
  end

  def new
    @ytnews = Ytnews.new
  end

  def create
    @ytnews = Ytnews.new(params[:ytnews])
    @ytnews.publish_time = Time.new
    if @ytnews.save
      flash[:notice] = '新建通知成功'
      redirect_to :action => 'list'
    else
      flash[:error] = '新建通知失败，请检查标题'
      render :action => 'new'
    end
  end

  def edit
    @ytnews = Ytnews.find(params[:id])
  end

  def update
    @ytnews = Ytnews.find(params[:id])
    if @ytnews.update_attributes(params[:ytnews])
      flash[:notice] = '修改通知成功'
      redirect_to :action => 'show', :id => @ytnews
    else
      flash[:notice] = '更新通知失败，请检查标题'
      render :action => 'edit'
    end
  end

  def destroy
    Ytnews.find(params[:id]).destroy
    flash[:notice] = '删除通知完毕'
    redirect_to :action => 'list'
  end
  
  def popup_new
    @ytnews = Ytnews.find(params[:id])
    save_browse(@ytnews)
    render :layout=> 'popup'
  end
  
  def browse_log
    @news = Ytnews.find(params[:id])
    @log_pages, @logs = paginate :ytapl_browselog, :per_page => 10, :order=>"id desc", :conditions=>"news_id=#{params[:id]}"
    #@logs = YtaplBrowselog.find(:all, :conditions=>"news_id=#{params[:id]}")
  end
  
private
  def save_browse(ytnews)
    b_log = YtaplBrowselog.new()
    b_log.news_id = ytnews['id']
    b_log.username = session[:user].truename
    b_log.browsetime = Time.new
    b_log.address = request.env_table['REMOTE_ADDR']
    b_log.save
  end
end
