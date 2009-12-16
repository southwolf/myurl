class PictureController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @pictures = Picture.paginate :page=>params[:page], :per_page => 20, :conditions=>"albumn_id = #{params[:id]}", :order=>"id desc"
  end

  def show
    @picture = Picture.find(params[:id])
  end

  def new
    @picture = Picture.new
  end

  def create
    @picture = Picture.new(params[:picture])
    @picture.albumn_id = params[:id]
    @picture.user_id = session[:user].id
    @picture.publish_time = Time.new
    if @picture.save
      flash[:notice] = '上传图片成功.'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @picture = Picture.find(params[:id])
  end

  def update
    @picture = Picture.find(params[:id])
    if @picture.update_attributes(params[:picture])
      flash[:notice] = 'Picture was successfully updated.'
      redirect_to :action => 'show', :id => @picture
    else
      render :action => 'edit'
    end
  end

  def destroy
    picture = Picture.find(params[:id])
    redirect_to :action => 'list', :id=> picture.albumn_id
    picture.destroy
    flash[:notice] = '删除图片成功'
  end
end
