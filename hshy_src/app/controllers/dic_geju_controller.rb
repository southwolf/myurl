class DicGejuController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @dic_gejus = DicGeju.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @dic_geju = DicGeju.find(params[:id])
  end

  def new
    @dic_geju = DicGeju.new
  end

  def create
    @dic_geju = DicGeju.new(params[:dic_geju])
    if @dic_geju.save
      flash[:notice] = 'DicGeju was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @dic_geju = DicGeju.find(params[:id])
  end

  def update
    @dic_geju = DicGeju.find(params[:id])
    if @dic_geju.update_attributes(params[:dic_geju])
      flash[:notice] = 'DicGeju was successfully updated.'
      redirect_to :action => 'show', :id => @dic_geju
    else
      render :action => 'edit'
    end
  end

  def destroy
    DicGeju.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
