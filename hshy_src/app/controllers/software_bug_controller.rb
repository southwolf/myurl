class SoftwareBugController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @software_bugs = SoftwareBug.paginate  :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"software_id = #{params[:id]}"
  end

  def show
    @software_bug = SoftwareBug.find(params[:id])
  end

  def new
    @software_bug = SoftwareBug.new
  end

  def create
    @software_bug = SoftwareBug.new(params[:software_bug])
    @software_bug.publish_time = Time.new
    @software_bug.publisher = session[:user].truename
    @software_bug.status = 1
    @software_bug.software_id = params[:id]
    if @software_bug.save
      flash[:notice] = '添加Bug成功'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @software_bug = SoftwareBug.find(params[:id])
  end

  def update
    @software_bug = SoftwareBug.find(params[:id])
    if @software_bug.update_attributes(params[:software_bug])
      flash[:notice] = '修改Bug成功'
      redirect_to :action => 'show', :id => @software_bug
    else
      render :action => 'edit'
    end
  end

  def destroy
    s = SoftwareBug.find(params[:id])
    redirect_to :action => 'list', :id=>s.software_id
    s.destroy
  end
  
  def finish
    @software_bug = SoftwareBug.find(params[:id])
  end
  
  def finish_submit
    @software_bug = SoftwareBug.find(params[:id])
    @software_bug.finish_time = Time.new
    @software_bug.finisher = session[:user].truename
    if @software_bug.update_attributes(params[:software_bug])
      flash[:notice] = '修改Bug成功'
      redirect_to :action => 'list', :id => @software_bug.software_id
    else
      render :action => 'finish_submit', :id=>params[:id]
    end
  end
  
end
