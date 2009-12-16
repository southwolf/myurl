class VisitController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @visit_pages, @visits = paginate :visits, :per_page => 20, :order=>"id desc"
  end
  
  def query
    condition = "1=1 and "
    condition += "linkman like '%#{params[:linkman]}%' " if params[:linkman].size > 0
    condition += "address like '%#{params[:address]}%'" if params[:address].size > 0
    condition += "unit_id = #{params[:unit_id]}" if params[:unit_id] != "-1"
    @visit_pages, @visits = paginate :visits, :per_page => 100, :order=>"id desc", :conditions=>condition
    render :action=>'list'
  end

  def show
    @visit = Visit.find(params[:id])
  end

  def new
    @visit = Visit.new
  end

  def create
    @visit = Visit.new(params[:visit])
    @visit.user_id = session[:user].id
    if @visit.save
      flash[:notice] = '添加拜访记录成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @visit = Visit.find(params[:id])
  end

  def update
    @visit = Visit.find(params[:id])
    if @visit.update_attributes(params[:visit])
      flash[:notice] = '修改拜访记录成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Visit.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
