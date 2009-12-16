class UnitController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @units = Unit.paginate :per_page => 20, :page=>params[:page]
  end
  
  def project_unit
    session[:current_project] = params[:id]
    @units = Project.find(params[:id]).units
  end
  
  def create_project_unit
    relation = ProjectUnit.new
    relation.project_id = session[:current_project]
    relation.unit_id = params[:unitid]
    relation.save
    flash[:notice] = '添加联系单位成功'
    redirect_to :action=>'project_unit', :id=>session[:current_project]
  end
  
  def destroy_project_relation
    ProjectUnit.delete_all("unit_id=#{params[:id]} and project_id=#{session[:current_project]}")
    flash[:notice] = '删除联系单位成功'
    redirect_to :action=>'project_unit', :id=>session[:current_project]
  end

  def show
    @unit = Unit.find(params[:id])
  end

  def new
    @unit = Unit.new
  end

  def create
    @unit = Unit.new(params[:unit])
    if @unit.save
      flash[:notice] = 'Unit was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @unit = Unit.find(params[:id])
  end

  def update
    @unit = Unit.find(params[:id])
    if @unit.update_attributes(params[:unit])
      flash[:notice] = 'Unit was successfully updated.'
      redirect_to :action => 'show', :id => @unit
    else
      render :action => 'edit'
    end
  end

  def destroy
    Unit.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def destroyfromedit
    Unit.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @unit = Unit.new
  end
  
  def result
    @unit = Unit.new(params[:unit])
    param = @unit.attribute_names
    condition = '1=1  '
    for p in param
      if @unit.attribute_present?(p)
        if @unit[p].type.to_s == 'Fixnum' || @unit[p].type.to_s == 'Bignum' || @unit[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @unit[p].to_s + ' '
        elsif @unit[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @unit[p].to_s + '%\' '
        elsif @unit[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @unit[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Unit.find(:all, :conditions =>condition).size()
    @unit_pages = Paginator.new self, count, 10, @params['page']
    @units = Unit.find_by_sql("select * from unit where #{condition} limit 10 OFFSET #{@unit_pages.current.to_sql[1]}")
    
    render :action => 'list'
  end
end
