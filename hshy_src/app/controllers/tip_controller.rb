class TipController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tip_pages, @tips = paginate :tips, :per_page => 10
  end

  def show
    @tip = Tip.find(params[:id])
  end

  def new
    @tip = Tip.new
  end

  def create
    @tip = Tip.new
    @tip.user_id = session[:user].id
    @tip.text = EncodeUtil.change("GB2312", "UTF-8", params[:value])
    @tip.save
    
    render :text=>@tip.text
  end

  def edit
    @tip = Tip.find(params[:id])
  end

  def update
    @tip = Tip.find(params[:id])
    if @tip.update_attributes(params[:tip])
      flash[:notice] = 'Tip was successfully updated.'
      redirect_to :action => 'show', :id => @tip
    else
      render :action => 'edit'
    end
  end

  def destroy
    Tip.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
