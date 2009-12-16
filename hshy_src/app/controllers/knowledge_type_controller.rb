class KnowledgeTypeController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @knowledge_types = KnowledgeType.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @knowledge_type = KnowledgeType.find(params[:id])
  end

  def new
    @knowledge_type = KnowledgeType.new
  end

  def create
    @knowledge_type = KnowledgeType.new(params[:knowledge_type])
    @knowledge_type.made_time = Time.new
    @knowledge_type.user = session[:user].truename
    if @knowledge_type.save
      flash[:notice] = '添加知识类型成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @knowledge_type = KnowledgeType.find(params[:id])
  end

  def update
    @knowledge_type = KnowledgeType.find(params[:id])
    if @knowledge_type.update_attributes(params[:knowledge_type])
      flash[:notice] = 'KnowledgeType was successfully updated.'
      redirect_to :action => 'show', :id => @knowledge_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    KnowledgeType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
