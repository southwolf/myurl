class WorkController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @works = Work.paginate :page=>params[:page], :per_page => 10, :conditions =>"person_id = #{session[:user].id}", :order => 'id desc'
  end  

  def show
    @work = Work.find(params[:id])
  end

  def new
    @work = Work.new
    @work.logtype = 1
  end

  def create
    @work = Work.new(params[:work])
    @work.person_id = session[:user].id
    @work.department_id = session[:user].department_id
    
    if @work.save
      flash[:notice] = '添加工作日志记录成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @work = Work.find(params[:id])
  end

  def update
    @work = Work.find(params[:id])
    @work.department_id = session[:user].department_id
    if @work.update_attributes(params[:work])
      flash[:notice] = '更改工作日志记录成功.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Work.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def destroyfromedit
    Work.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @work = Work.new
  end
  
  def result
    @work = Work.new(params[:work])
    param = @work.attribute_names
    condition = '1=1  '
    for p in param
      if @work.attribute_present?(p)
        if @work[p].type.to_s == 'Fixnum' || @work[p].type.to_s == 'Bignum' || @work[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @work[p].to_s + ' '
        elsif @work[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @work[p].to_s + '%\' '
        elsif @work[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @work[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Work.find(:all, :conditions =>condition).size()
    @work_pages = Paginator.new self, count, 10, @params['page']
    @works = Work.find_by_sql("select * from work where #{condition} limit 10 OFFSET #{@work_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
end
