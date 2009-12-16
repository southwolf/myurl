class KnowledgeController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
   @knowledges = Knowledge.paginate :page=>params[:page], :per_page => 10, :conditions=>"type_id = #{params[:id]}", :order=>"id desc"
  end

  def show
    @knowledge = Knowledge.find(params[:id])
  end

  def new
    @knowledge = Knowledge.new
  end

  def create
    @knowledge = Knowledge.new(params[:knowledge])
    @knowledge.type_id = params[:id]
    @knowledge.publish_time = Time.new
    @knowledge.publisher = session[:user].truename
    if @knowledge.save
      flash[:notice] = '添加知识成功.'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new'
    end
  end

  def edit
    @knowledge = Knowledge.find(params[:id])
  end

  def update
    @knowledge = Knowledge.find(params[:id])
    if @knowledge.update_attributes(params[:knowledge])
      flash[:notice] = '更新知识成功'
      redirect_to :action => 'list', :id=>@knowledge.type_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    knowledge = Knowledge.find(params[:id])
    redirect_to :action => 'list', :id=>knowledge.type_id
    knowledge.destroy
  end
  
  def download_attach1
    knowledge = Knowledge.find(params[:id])
    send_file knowledge.attach1
  end
  
  def download_attach2
    knowledge = Knowledge.find(params[:id])
    send_file knowledge.attach2
  end
  
  def download_attach3
    knowledge = Knowledge.find(params[:id])
    send_file knowledge.attach3
  end
end
