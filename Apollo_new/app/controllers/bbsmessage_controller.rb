class BbsmessageController < ApplicationController
  layout "main"
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bbsmessage_pages, @bbsmessages = paginate :bbsmessages, :per_page => 20, :order => "id desc"
  end

  def show
    @bbsmessage = Bbsmessage.find(params[:id])
  end

  def new
    @bbsmessage = Bbsmessage.new
  end

  def create
    @bbsmessage = Bbsmessage.new(params[:bbsmessage])
    @bbsmessage.username = session[:user].name
    @bbsmessage.time = Time.new
    if @bbsmessage.save
      flash[:notice] = '添加留言成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bbsmessage = Bbsmessage.find(params[:id])
    #防止有人故意乱敲网址
    if @bbsmessage.username != session[:user].name
      flash[:error] = '您无权更改此留言'
      redirect_to :action=>'list'
    end
  end

  def update
    if CheckRight(session[:user].id, "删除留言")
      flash[:error] = '您无权删除留言'
      redirect_to :action=>'list'
    end
    @bbsmessage = Bbsmessage.find(params[:id])
    @bbsmessage.time = Time.new
    if @bbsmessage.update_attributes(params[:bbsmessage])
      flash[:notice] = '更新留言成功'
      redirect_to :action => 'show', :id => @bbsmessage
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bbsmessage.find(params[:id]).destroy
    flash[:notice] = '删除留言成功'
    redirect_to :action => 'list'
  end
  
  def destroyfromedit
    Bbsmessage.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @bbsmessage = Bbsmessage.new
  end
  
  def result
    @bbsmessage = Bbsmessage.new(params[:bbsmessage])
    param = @bbsmessage.attribute_names
    condition = '1=1  '
    for p in param
      if @bbsmessage.attribute_present?(p)
        if @bbsmessage[p].type.to_s == 'Fixnum' || @bbsmessage[p].type.to_s == 'Bignum' || @bbsmessage[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @bbsmessage[p].to_s + ' '
        elsif @bbsmessage[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @bbsmessage[p].to_s + '%\' '
        elsif @bbsmessage[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @bbsmessage[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Bbsmessage.find(:all, :conditions =>condition).size()
    @bbsmessage_pages = Paginator.new self, count, 10, @params['page']
    @bbsmessages = Bbsmessage.find_by_sql("select * from bbsmessages where #{condition} limit 10 OFFSET #{@bbsmessage_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
end
