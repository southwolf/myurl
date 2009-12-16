class ProductRejectController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_rejects = ProductReject.paginate :page=>params[:page], :per_page=>20, :order=>"id desc"
  end

  def show
    @product_reject = ProductReject.find(params[:id])
    
    params[:id] = @product_reject.product[0]._cata_id rescue nil
    get_cells
  end

  def new
    @product_reject = ProductReject.new
  end

  def create
    @product_reject = ProductReject.new(params[:product_reject])
    @product_reject.dealtime = Time.new
    @product_reject.dealer = session[:user].truename
    if @product_reject.save
      for id in params["c#{params[:id]}"]
        e = ProductProductReject.new
        e.e_id = @product_reject.id
        e.p_id = id
        e.save
        
         product = Product.find(id)
         product._status = 0      #库存状态
         product.save
         
        log = ProductLog.new
        log.product_id = product.id
        log.text = "退货，原因:#{@product_reject.desc}"
        log.dealer = session[:user].truename
        log.dealtime = Time.new
        log.save
      end
      flash[:notice] = '退货成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product_reject = ProductReject.find(params[:id])
  end

  def update
    @product_reject = ProductReject.find(params[:id])
    if @product_reject.update_attributes(params[:product_reject])
      flash[:notice] = 'ProductReject was successfully updated.'
      redirect_to :action => 'show', :id => @product_reject
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProductReject.find(params[:id]).destroy
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
