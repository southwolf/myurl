class ProductBatchController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_batches = ProductBatch.paginate :page=>params[:page], :per_page => 10
  end

  def show
    @product_batch = ProductBatch.find(params[:id])
    
    attr = ProductAttr.find(@product_batch._cata_id)
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:record=>@product_batch, :encoding=>"gb2312", :script=>helper.script})
    @tableid = helper.tables[0].GetTableID()
    
    @products = Product.find(:all, :conditions=>"_pici=#{@product_batch.id}")
  end

  def new
    @product_batch = ProductBatch.new
    @product_batch._cata_id = params[:cata]
    
    attr = ProductAttr.find(params[:cata])
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script})
    @tableid = helper.tables[0].GetTableID()
  end

  def create
    @product_batch = ProductBatch.new(params[:product_batch])
    @product_batch.update_attributes(params[params[:tableid]])
    if @product_batch.save
      flash[:notice] = '创建生产批次成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product_batch = ProductBatch.find(params[:id])
  end

  def update
    @product_batch = ProductBatch.find(params[:id])
    if @product_batch.update_attributes(params[:product_batch])
      flash[:notice] = 'ProductBatch was successfully updated.'
      redirect_to :action => 'show', :id => @product_batch
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProductBatch.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
