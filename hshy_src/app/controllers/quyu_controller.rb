class QuyuController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @quyus = Quyu.find(:all)
  end

  def show
    @quyu = Quyu.find(params[:id])
  end

  def new
    @quyu = Quyu.new
  end

  def create
    @quyu = Quyu.new(params[:quyu])
    if @quyu.save
      flash[:notice] = 'Quyu was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @quyu = Quyu.find(params[:id])
  end

  def update
    @quyu = Quyu.find(params[:id])
    if @quyu.update_attributes(params[:quyu])
      flash[:notice] = 'ÐÞ¸Ä³É¹¦'
      redirect_to :action => 'list', :id => @quyu
    else
      render :action => 'edit'
    end
  end

  def destroy
    Quyu.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def detail
    #@dic_dizhis = DicDizhi.find(:all, :conditions=>"quyu_id=#{params[:id]}")
    render :partial=>"detail", :locals=>{:dic_dizhis=>DicDizhi.find(:all, :conditions=>"quyu_id=#{params[:id]}")}, :layout=>false
  end
end
