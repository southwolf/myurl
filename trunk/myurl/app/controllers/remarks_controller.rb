class RemarksController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @remarks_pages, @remarks = paginate :remarks, :per_page => 10
  end

  def show
    @remarks = Remarks.find(params[:id])
  end

  def new
    @remarks = Remarks.new
  end

  def create
    @remarks = Remarks.new(params[:remarks])
    if @remarks.save
      flash[:notice] = 'Remarks was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @remarks = Remarks.find(params[:id])
  end

  def update
    @remarks = Remarks.find(params[:id])
    if @remarks.update_attributes(params[:remarks])
      flash[:notice] = 'Remarks was successfully updated.'
      redirect_to :action => 'show', :id => @remarks
    else
      render :action => 'edit'
    end
  end

  def destroy
    Remarks.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
