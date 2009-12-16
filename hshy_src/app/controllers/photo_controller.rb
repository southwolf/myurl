class PhotoController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@photo_pages, @photos = paginate :photos, :per_page => 10
    @pictures = House.find(params[:id]).photo
  end

  def show
    @photo = Photo.find(params[:id])
  end
  
  def flexshow
    @photo = Photo.find(params[:id])
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(params[:photo])
    @photo.house_id = params[:id]
    @photo.publisher = session[:user].truename
    @photo.publish_time = Time.new
    if @photo.save
      flash[:notice] = '添加房源信息成功'
      if @photo.house.tag == 1
        redirect_to :controller=>"house", :action => 'sell_list'
      else
        redirect_to :controller=>"house", :action => 'rent_list'
      end
      
    else
      render :action => 'new'
    end
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:notice] = 'Photo was successfully updated.'
      redirect_to :action => 'show', :id => @photo
    else
      render :action => 'edit'
    end
  end

  def destroy
    photo = Photo.find(params[:id])
    redirect_to :action => 'list', :id=>photo.house_id
    photo.destroy
    
  end
end
