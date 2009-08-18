class RecommandsController < ApplicationController
  before_filter :admin_required
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:id]
      @recommands = Recommand.paginate :page=>params[:page], :per_page => 10,:conditions=>"label_id=#{params[:id]}"
    else
      @recommands = Recommand.paginate :page=>params[:page], :per_page => 10
    end
  end

  def new
    @recommands = Recommand.new
    @recommands.label_id = params[:id] || 1
  end

  def create
    @recommands = Recommand.new(params[:recommands])
    if @recommands.save
      flash[:notice] = '添加推荐网站成功'
      redirect_to :action => 'list', :id=>@recommands.label_id
    else
      render :action => 'new'
    end
  end

  def edit
    @recommands = Recommand.find(params[:id])
  end

  def update
    @recommands = Recommand.find(params[:id])
    if @recommands.update_attributes(params[:recommands])
      flash[:notice] = '修改推荐网站成功'
      redirect_to :action => 'list', :id => @recommands.label_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    Recommand.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = Label.find(node)
      child.order = index
      child.save
      index += 1
    end
    
    render :text=>'排序成功'
  end
end
