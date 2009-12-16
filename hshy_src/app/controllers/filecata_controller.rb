class FilecataController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @filecatas = Filecata.paginate :page=>params[:page], :per_page => 20, :order=>"position"
  end

  def show
    @filecata = Filecata.find(params[:id])
  end

  def new
    @filecata = Filecata.new
  end

  def create
    @filecata = Filecata.new(params[:filecata])
    @filecata.publisher = session[:user].truename
    @filecata.publish_time = Time.new
    if @filecata.save
      flash[:notice] = '创建文档类别成功.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @filecata = Filecata.find(params[:id])
  end

  def update
    @filecata = Filecata.find(params[:id])
    if @filecata.update_attributes(params[:filecata])
      flash[:notice] = '修改类别成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Filecata.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def destroyfromedit
    Filecata.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @filecata = Filecata.new
  end
  
  def result
    @filecata = Filecata.new(params[:filecata])
    param = @filecata.attribute_names
    condition = '1=1  '
    for p in param
      if @filecata.attribute_present?(p)
        if @filecata[p].type.to_s == 'Fixnum' || @filecata[p].type.to_s == 'Bignum' || @filecata[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @filecata[p].to_s + ' '
        elsif @filecata[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @filecata[p].to_s + '%\' '
        elsif @filecata[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @filecata[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Filecata.find(:all, :conditions =>condition).size()
    @filecata_pages = Paginator.new self, count, 10, @params['page']
    @filecatas = Filecata.find_by_sql("select * from filecatas where #{condition} limit 10 OFFSET #{@filecata_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
  
  def reorder
    @catas = Filecata.find(:all, :order=>"position")
    render :layout=>"notoolbar_app"
  end
  
  def order
    index = 1
    for node in params[:nodelist]
      child = Filecata.find(node)
      child.position = index
      child.save
      index += 1
    end
  end
end
