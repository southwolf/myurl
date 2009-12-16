class DicLouhaoController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @dic_louhaos = DicLouhao.find(:all, :conditions=>"quyu_id = #{params[:id]}")
    render :layout=>false
  end

  def show
    @dic_louhao = DicLouhao.find(params[:id])
  end

  def new
    @dic_louhao = DicLouhao.new
    render :layout=>false
  end

  def create
    @dic_louhao = DicLouhao.new(params[:dic_louhao])
    @dic_louhao.quyu_id = params[:id]
    if @dic_louhao.save
 #     flash[:notice] = 'DicLouhao was successfully created.'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @dic_louhao = DicLouhao.find(params[:id])
  end

  def update
    @dic_louhao = DicLouhao.find(params[:id])
    if @dic_louhao.update_attributes(params[:dic_louhao])
      flash[:notice] = 'DicLouhao was successfully updated.'
      redirect_to :action => 'show', :id => @dic_louhao
    else
      render :action => 'edit'
    end
  end

  def destroy
    l = DicLouhao.find(params[:id])
    l.destroy
    redirect_to :action => 'list', :id=>l.quyu_id
  end
end
