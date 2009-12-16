class HouselogController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @house = House.find(params[:id])
    @houselogs = Houselog.paginate :page=>params[:page], :conditions=>"house_id=#{params[:id]}", :per_page => 20
  end

  def show
    @houselog = Houselog.find(params[:id])
  end

  def new
    @houselog = Houselog.new
  end

  def create
    house = House.find(params[:id])
    
    @houselog = Houselog.new(params[:houselog])
    @houselog.house_id = params[:id]
    @houselog.inputer = session[:user].truename
    @houselog.inputtime = Time.new
    
    Viewlog.delete_all "house_id = #{params[:id]} and user_id = #{session[:user].id}" 
    
    if @houselog.save
      flash[:notice] = '添加跟进记录成功'
      if params[:search] == "true"
        render :text=>'添加跟进记录成功'
        return
      end
      
      
      if house.tag == 1
        redirect_to :controller=>"house", :action=>"sell_list", :page=>house.page
      else
        redirect_to :controller=>"house", :action=>"rent_list", :page=>house.page
      end
      
      #redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @houselog = Houselog.find(params[:id])
  end

  def update
    @houselog = Houselog.find(params[:id])
    if @houselog.update_attributes(params[:houselog])
      if @houselog.house.tag == 1
        redirect_to :controller=>"house", :action=>"sell_list", :page=>@houselog.house.page
      else
        redirect_to :controller=>"house", :action=>"rent_list", :page=>@houselog.house.page
      end
      #flash[:notice] = 'Houselog was successfully updated.'
      #redirect_to :action => 'show', :id => @houselog
    else
      render :action => 'edit'
    end
  end

  def destroy
    log = Houselog.find(params[:id])
    log.destroy
    redirect_to :action => 'list', :id=>log.house.id
  end
  
  def tongji
    @departments = Department.find(:all)
    if params[:id]
      user = YtwgUser.find(params[:id])
      @logs = Houselog.paginate :page=>params[:page], :conditions=>"inputer = '#{user.truename}'", :per_page => 20
    end
  end
end
