class FileimageController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @fileimages = Fileimage.paginate :page=>params[:page], :per_page => 10, :order=>"id desc"
  end

  def show
    @fileimage = Fileimage.find(params[:id])
  end

  def new
    @fileimage = Fileimage.new
  end

  def create
    @fileimage = Fileimage.new(params[:fileimage])
    @fileimage.publisher = session[:user].truename
    @fileimage.publish_time = Time.new
    if @fileimage.save
      flash[:notice] = '上传映像文件成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @fileimage = Fileimage.find(params[:id])
  end

  def update
    @fileimage = Fileimage.find(params[:id])
    if @fileimage.update_attributes(params[:fileimage])
      flash[:notice] = 'Fileimage was successfully updated.'
      redirect_to :action => 'show', :id => @fileimage
    else
      render :action => 'edit'
    end
  end

  def destroy
    Fileimage.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def download
    image = Fileimage.find(params[:id])
    send_file image.path
  end
end
