class ProductExportController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@product_export_pages, @product_exports = paginate :product_exports, :per_page => 10
    @product_exports = ProductExport.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
  end

  def show
    @product_export = ProductExport.find(params[:id])
    
    params[:id] = @product_export.product[0]._cata_id
    get_cells
  end

  def new
    @product_export = ProductExport.new
  end

  def create
    @product_export = ProductExport.new(params[:product_export])
    @product_export.dealtime = Time.new
    @product_export.dealer = session[:user].truename
    if @product_export.save
      for id in params["c#{params[:id]}"]
        e = ProductProductExport.new
        e.e_id = @product_export.id
        e.p_id = id
        e.save
        
        product = Product.find(id)
        product._status = 1
        product.save
        
        log = ProductLog.new
        log.product_id = product.id
        log.text = "出库售出到#{@product_export.unitname}"
        log.dealer = session[:user].truename
        log.dealtime = Time.new
        log.save
      end
      flash[:notice] = '出库成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product_export = ProductExport.find(params[:id])
  end

  def update
    @product_export = ProductExport.find(params[:id])
    if @product_export.update_attributes(params[:product_export])
      flash[:notice] = 'ProductExport was successfully updated.'
      redirect_to :action => 'show', :id => @product_export
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProductExport.find(params[:id]).destroy
    redirect_to :action => 'list'
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
