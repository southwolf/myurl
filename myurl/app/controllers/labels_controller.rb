class LabelsController < ApplicationController
  before_filter :admin_required
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @labels = Label.paginate :page=>params[:page], :per_page => 20, :order=>"`order`"
  end

  def show
    @labels = Label.find(params[:id])
  end

  def new
    @labels = Label.new
  end

  def create
    @labels = Label.new(params[:labels])
    if @labels.save
      flash[:notice] = 'Labels was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @labels = Label.find(params[:id])
  end

  def update
    @labels = Label.find(params[:id])
    if @labels.update_attributes(params[:labels])
      flash[:notice] = '修改成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Label.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
