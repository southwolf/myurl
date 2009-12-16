class DocumentController < ApplicationController
  def index
    list
    render :action => 'list', :id=>params[:id]
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
      @documents = Documentfile.paginate :page=>params[:page], :per_page => 10, :conditions => "cata_id = #{params[:id]}", :order => 'id desc'
  end

  def show
    @document = Documentfile.find(params[:id])
  end

  def new
    @document = Documentfile.new
  end

  def create
    @document = Documentfile.new(params[:documentfile])
    @document.cata_id = params[:id]
    @document['publish_time'] = Time.new
    @document['publisher'] = session[:user].truename 
    if @document.save
      flash[:notice] = '成功上传文档'
      redirect_to :action => 'list', :id=>params[:id]
    else
      render :action => 'new', :id=>params[:id]
    end
  end

  def edit
    @document = Documentfile.find(params[:id])
  end

  def update
    @document = Documentfile.find(params[:id])
    if @document.update_attributes(params[:documentfile])
      flash[:notice] = 'Document was successfully updated.'
      redirect_to :action => 'show', :id => @document
    else
      render :action => 'edit'
    end
  end

  def destroy
    file = Documentfile.find(params[:id])
    redirect_to :action => 'list', :id=>file.cata_id
    file.destroy
  end
  
  def destroyfromedit
    Documentfile.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @document = Document.new
  end
  
  def result
    @document = Documentfile.new(params[:document])
    param = @document.attribute_names
    condition = '1=1  '
    for p in param
      if @document.attribute_present?(p)
        if @document[p].type.to_s == 'Fixnum' || @document[p].type.to_s == 'Bignum' || @document[p].type.to_s == 'Float'
          condition += 'and ' + p + ' = ' + @document[p].to_s + ' '
        elsif @document[p].type.to_s == 'String'
          condition += 'and ' + p + ' like \'%' + @document[p].to_s + '%\' '
        elsif @document[p].type.to_s == 'Time'          
          #condition += 'and ' + p + '= \'' + @document[p].strftime("%Y-%m-%d") + '\' '
        end
      end
    end
    
    count = Documentfile.find(:all, :conditions =>condition).size()
    @document_pages = Paginator.new self, count, 10, @params['page']
    @documents = Documentfile.find_by_sql("select * from documents where #{condition} limit 10 OFFSET #{@document_pages.current.to_sql[1]}")
    
    render :action => 'list'
      
  end
  
  def download
    d = Documentfile.find(params[:id])
    send_file d.path
  end
end
