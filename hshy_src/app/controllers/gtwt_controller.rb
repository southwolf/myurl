class GtwtController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @gtwts = Gtwt.paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def show
    @gtwt = Gtwt.find(params[:id])
  end

  def new
    @gtwt = Gtwt.new
  end

  def create
    @gtwt = Gtwt.new(params[:gtwt])
    @gtwt.publisher = session[:user].truename
    if @gtwt.save
      flash[:notice] = '提交问题成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @gtwt = Gtwt.find(params[:id])
  end

  def update
    @gtwt = Gtwt.find(params[:id])
    if @gtwt.update_attributes(params[:gtwt])
      flash[:notice] = 'Gtwt was successfully updated.'
      redirect_to :action => 'show', :id => @gtwt
    else
      render :action => 'edit'
    end
  end

  def destroy
    Gtwt.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
