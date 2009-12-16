class PhonecontractController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @phonecontract_pages, @phonecontracts = paginate :phonecontracts, :per_page => 20, :order=>"id desc"
  end
  
  def query
    condition = "1=1 and "
    condition += "linkman like '%#{params[:linkman]}%' " if params[:linkman].size > 0
    condition += "telephone like '%#{params[:telephone]}%'" if params[:telephone].size > 0
    condition += "unit_id = #{params[:unit_id]}" if params[:unit_id] != "-1"
    @phonecontract_pages, @phonecontracts = paginate :phonecontracts, :per_page => 100, :order=>"id desc", :conditions=>condition
    render :action=>'list'
  end

  def show
    @phonecontract = Phonecontract.find(params[:id])
  end

  def new
    @phonecontract = Phonecontract.new
  end

  def create
    @phonecontract = Phonecontract.new(params[:phonecontract])
    @phonecontract.user_id = session[:user].id
    if @phonecontract.save
      flash[:notice] = '添加电话访问记录成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @phonecontract = Phonecontract.find(params[:id])
  end

  def update
    @phonecontract = Phonecontract.find(params[:id])
    if @phonecontract.update_attributes(params[:phonecontract])
      flash[:notice] = '修改电话访问记录成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Phonecontract.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
