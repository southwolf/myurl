class NewsController < ApplicationController
  def index
    session[:topic] = Topic.find(params[:topic]);
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@news_pages, @news = paginate :news, :per_page => 10, :conditions => "栏目=#{session[:topic].id}", :order => 'id desc'
    #@news = News.paginate :page=>params[:page], :per_page => 10, :conditions => "topic=#{session[:topic].id}", :order => 'id desc'
    @news = News.paginate :per_page=>10, :page=>params[:page], :conditions => "topic=#{session[:topic].id}", :order => 'id desc'
  end

  def show
    @news = News.find(params[:id])
  end
  
  def popup_news
    @news = News.find(params[:id])
    render :layout=>'popup'
  end

  def new
    @news = News.new
  end

  def create
    @news = News.new(params[:news])
    @news['topic'] = session[:topic].id 
    @news['publisher'] = session[:user].id
    @news['publishtime'] = Time.new
    if @news.save
      flash[:notice] = '帖子发布成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @news = News.find(params[:id])
  end

  def update
    @news = News.find(params[:id])
    if @news.update_attributes(params[:news])
      flash[:notice] = '修改帖子成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    News.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def destroyfromedit
    News.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @news = News.new
  end
  
  def result
    @news = News.new(params[:news])
    param = @news.attribute_names
    condition = '1=1  '
    for p in param
      if @news.attribute_present?(p)
        if @news[p].type.to_s == 'Fixnum' || @news[p].type.to_s == 'Bignum' || @news[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @news[p].to_s + ' '
        elsif @news[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @news[p].to_s + '%\' '
        elsif @news[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @news[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = News.find(:all, :conditions =>condition).size()
    @news_pages = Paginator.new self, count, 10, @params['page']
    @newss = News.find_by_sql("select * from news where #{condition} limit 10 OFFSET #{@news_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
  
  def save_reply
    @bbsmessage = News.new(params[:bbsmessage])
    @bbsmessage.content = params[:reply]
    @bbsmessage.parentbbs = params[:id]
    @bbsmessage.publishtime = Time.new
    @bbsmessage.publisher = session[:user].id
    if @bbsmessage.save
      flash[:notice] = '回贴成功'
      #render :partial=>"reply", :locals=>{:bbsmessage=>Bbsmessage.find(params[:id])}, :layout=>false
      redirect_to :action => 'list'
    else
      redirect_to :action => 'list'
    end
  end
  
  def reply
    render :layout=>false
  end
end
