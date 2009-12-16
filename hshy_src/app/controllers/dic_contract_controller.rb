class DicContractController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @dic_contracts = DicContract.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @dic_contract = DicContract.find(params[:id])
  end

  def new
    @dic_contract = DicContract.new
  end

  def create
    @dic_contract = DicContract.new(params[:dic_contract])
    if @dic_contract.save
      flash[:notice] = '添加字典成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @dic_contract = DicContract.find(params[:id])
  end

  def update
    @dic_contract = DicContract.find(params[:id])
    if @dic_contract.update_attributes(params[:dic_contract])
      flash[:notice] = '修改字典成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    DicContract.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
