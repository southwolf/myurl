class TaskController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@task_pages, @tasks = paginate :tasks, :per_page => 10
    @tasks_from_me = Task.find(:all, :conditions=>"user_id=#{session[:user].id} and recv_id<>#{session[:user].id}")
    @tasks_to_me = Task.find(:all, :conditions=>"recv_id=#{session[:user].id}")
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    for user_id in params[:recv]
      @task = Task.new(params[:task])
      @task.user_id = session[:user].id
      @task.recv_id = user_id
      @task.status = 1          #新下发
      @task.publish_time = Time.new
      @task.save
    end
    flash[:notice] = '创建任务完毕'
    redirect_to :action => 'list'
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(params[:task])
      flash[:notice] = 'Task was successfully updated.'
      redirect_to :action => 'show', :id => @task
    else
      render :action => 'edit'
    end
  end

  def destroy
    flash[:notice] = "删除下发任务成功"
    Task.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def accept
    task = Task.find(params[:id])
    if params[:flag] == "refuse"
      task.status = 5
    else
      task.status = 2
    end
    task.save
    redirect_to :action => 'list'
  end
  
  def complete
    @task = Task.find(params[:id])
  end
  
  def reply
    @task = Task.find(params[:id])
    @task.update_attributes(params[:task])
    if params[:flag]=="1"
      @task.status = 3
    else
      @task.status = 4
    end
    @task.save
    redirect_to :action => 'list'
  end
end
