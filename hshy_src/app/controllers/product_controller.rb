class ProductController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_catas = ProductCata.find(:all)
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(params[:product])
    if @product.save
      flash[:notice] = 'Product was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      flash[:notice] = 'Product was successfully updated.'
      redirect_to :action => 'show', :id => @product
    else
      render :action => 'edit'
    end
  end

  def destroy
    Product.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def new_batch
    attr = ProductAttr.find(params[:id])
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script})
    @tableid = helper.tables[0].GetTableID()
  end
  
  def create_batch
    attr = ProductAttr.find(params[:id])
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    @tableid = helper.tables[0].GetTableID()
    
    1.upto(params[:num].to_i) do  
      p = Product.new
      p._cata_id = params[:id]
      p.update_attributes(params[@tableid])
      p.barcode = "%04d" % params[:id] + "%06d" % p.id
      p.save
      
      log = ProductLog.new
      log.product_id = p.id
      log.text = "采购入库"
      log.dealer = session[:user].truename
      log.dealtime = Time.new
      log.n_cata_id = params[:id]
      log.n_product_id = p.id
      log.save
    end
    
    redirect_to :action=>"list"
  end
  
  def list_detail
    @products = Product.paginate :page=>params[:page], :per_page => 20, :conditions=>"_cata_id = #{params[:id]}"
    get_cells
  end
  
  def new_comp
    @cata = ProductCata.find(params[:id])
    @composites = ProductComposite.find(:all, :conditions=>"p_id = #{params[:id]}")
    
    @product = Product.new
    @product._cata_id = params[:id]
    
    attr = ProductAttr.find(params[:id])
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    @style = helper.StyleToHTML(helper.tables[0])
    
    record = {}
    if params[:batch]
      record = ProductBatch.find(params[:batch])
      @product._pici = params[:batch]
    end
    
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:record=>record, :encoding=>"gb2312", :script=>helper.script})
    @tableid = helper.tables[0].GetTableID()
  end
  
  def select_composite
    condition = "(_status is null or _status = 0)"
    condition = "_status = #{params[:status]}" if params[:status]
    @products = Product.find(:all, :conditions=>"_cata_id = #{params[:id]} and #{condition}")
    get_cells
    render :layout=>false
  end
  
  def create_comp
    cata = ProductCata.find(params[:id])
    
    @product = Product.new(params[:product])
    @product._cata_id = params[:id]
    @product.update_attributes(params[params[:tableid]])
    if params[:product][:barcode].to_s.size == 0
      @product.barcode = "%04d" % params[:id] + "%06d" % @product.id 
      @product.save
    end

    for c in cata.composite
      ids = params["c"+c.sub_id.to_s]
      for id in ids
        sub = Product.find(id)
        sub._parent_id = @product.id
        sub._status = 4
        sub.save       
        
        log = ProductLog.new
        log.product_id = sub.id
        log.text = "被组装到器件#{@product.barcode}"
        log.dealer = session[:user].truename
        log.dealtime = Time.new
        log.o_product_id = sub.parent.id
        log.n_product_id = sub.id
        log.save
        
      end if ids
    end
    
    log = ProductLog.new
    log.product_id = @product.id
    log.text = "组装入库"
    log.dealer = session[:user].truename
    log.dealtime = Time.new
    log.n_cata_id = params[:id]
    log.n_product_id = @product.id
    log.save
    
    redirect_to :action=>"list"
  end
  
  def show_product    
    @product = Product.find(params[:id])
    @composites = ProductCata.find(@product.cata.id).composite
    
    attr = ProductAttr.find(@product.cata.id)
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:record => @product, :encoding=>"gb2312", :script=>helper.script})
    params[:id] = @product.cata.id
    get_cells
  end
  
  #拆装
  def delete_comp
    @product = Product.find(params[:id])
  end
  
  #拆装
  def destroy_comp
    p params
    @product = Product.find(params[:id])
    @product._status = 5    #被拆装状态
    log = ProductLog.new
    log.product_id = @product.id
    log.text = "被拆装,原因:#{params[:reason]}"
    log.dealer = session[:user].truename
    log.dealtime = Time.mktime(params[:date][:year], params[:month], params[:day], 0, 0, 0)
    log.save
    @product.save
    
    for child in @product.children
      child._parent_id = nil
      child._status = 0       #入库状态
      child.save
      log = ProductLog.new
      log.product_id = child.id
      log.text = "从#{@product.barcode}上被拆装,原因:#{params[:reason]}"
      log.dealer = session[:user].truename
      log.dealtime = Time.mktime(params[:date][:year], params[:month], params[:day], 0, 0, 0)
      log.o_product_id = @product.id
      log.n_product_id = nil
      log.save
    end
    
    redirect_to :action=>"list_detail", :id=>@product._cata_id
  end
  
  def edit_repair
    product = Product.find(params[:id])
    product._status = 0     #状态为库存
    product.save
    log = ProductLog.new
    log.product_id = params[:id]
    log.text = "维修，内容:#{params[:text]}"
    log.dealer = session[:user].truename
    log.dealtime = Time.new
    log.save
    redirect_to :action=>"show_product", :id=>params[:id]
  end
  
  def edit_breakdown
    product = Product.find(params[:id])
    product._status = 3     #状态为库存
    product.save
    log = ProductLog.new
    log.product_id = params[:id]
    log.text = "损坏，内容:#{params[:text]}"
    log.dealer = session[:user].truename
    log.dealtime = Time.new
    log.save
    redirect_to :action=>"show_product", :id=>params[:id]
  end
  
  def new_pici
    
  end
  
private
  def get_cells
    @cells = {}
    attr = ProductAttr.find(params[:id])
    helper = XMLHelper.new
    helper.ReadFromString(attr.interface)
    formtable = helper.tables[0]
    Integer(0).upto(formtable.GetRowCount()-1) do |row|
        next if formtable.IsEmptyRow(row)
        Integer(0).upto(formtable.GetColumnCount()-1) do |col|
          next if formtable.IsEmptyCol(col)
          cell = formtable.GetCell(row, col)
          next if !cell.IsStore || !cell.IsEffective
          desc = EncodeUtil.change("GB2312", "UTF-8",cell.GetDescription)
          @cells[formtable.GetCellDBFieldName(row, col).downcase] = desc if desc.size > 0
        end
    end
  end
end
