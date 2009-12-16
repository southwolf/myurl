class TopicController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @topics = Topic.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])
    if @topic.save
      flash[:notice] = '创建板块成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = '修改板块成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Topic.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def destroyfromedit
    Topic.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @topic = Topic.new
  end
  
  def result
    @topic = Topic.new(params[:topic])
    param = @topic.attribute_names
    condition = '1=1  '
    for p in param
      if @topic.attribute_present?(p)
        if @topic[p].type.to_s == 'Fixnum' || @topic[p].type.to_s == 'Bignum' || @topic[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @topic[p].to_s + ' '
        elsif @topic[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @topic[p].to_s + '%\' '
        elsif @topic[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @topic[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Topic.find(:all, :conditions =>condition).size()
    @topic_pages = Paginator.new self, count, 10, @params['page']
    @topics = Topic.find_by_sql("select * from topics where #{condition} limit 10 OFFSET #{@topic_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
end
