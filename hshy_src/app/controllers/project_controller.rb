class ProjectController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def progress
    redirect_to :controller=>"projectprogress", :action=>"list", :id=>params[:id]
  end
  
  def list
    @projects = Project.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = '添加项目成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      flash[:notice] = '修改项目信息成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def unit_project
    @projects = Unit.find(params[:id]).projects
  end
  
  def linkman_project
    @projects = Linkman.find(params[:id]).projects
    render :action=>'unit_project'
  end
  
  def destroyfromedit
    Project.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @project = Project.new
  end
  
  def result
    @project = Project.new(params[:project])
    param = @project.attribute_names
    condition = '1=1  '
    for p in param
      if @project.attribute_present?(p)
        if @project[p].type.to_s == 'Fixnum' || @project[p].type.to_s == 'Bignum' || @project[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @project[p].to_s + ' '
        elsif @project[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @project[p].to_s + '%\' '
        elsif @project[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @project[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Project.find(:all, :conditions =>condition).size()
    @project_pages = Paginator.new self, count, 10, @params['page']
    @projects = Project.find_by_sql("select * from projects where #{condition} limit 10 OFFSET #{@project_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
end
