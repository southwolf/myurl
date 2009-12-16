class ProductCataController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_cata_pages, @product_catas = paginate :product_catas, :per_page => 10
  end

  def show
    @product_cata = ProductCata.find(params[:id])
  end

  def new
    @product_cata = ProductCata.new
  end

  def create
    @product_cata = ProductCata.new(params[:product_cata])
    if @product_cata.save
      flash[:notice] = '创建产品种类成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product_cata = ProductCata.find(params[:id])
  end

  def update
    @product_cata = ProductCata.find(params[:id])
    if @product_cata.update_attributes(params[:product_cata])
      flash[:notice] = '修改产品种类成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProductCata.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def composite
    @product_cata = ProductCata.find(params[:id])
    @composites = ProductComposite.find(:all, :conditions=>"p_id = #{@product_cata.id}")
  end
  
  def new_composite
    @composite = ProductComposite.new
    @composite.selectable = 0
  end
  
  def create_composite
    @composite = ProductComposite.new(params[:composite])
    @composite.p_id = params[:id]
    @composite.save
    redirect_to :action=>"composite", :id=>params[:id]
  end
  
  def delete_composite
    composite = ProductComposite.find(params[:id])
    composite.destroy
    redirect_to :action=>"composite", :id=>composite.p_id
  end
  
  def new_prop
    stream = params[:product_attr]
    content = stream.read
    
    attr = ProductAttr.new
    attr.id = params[:id]
    attr.interface = content
    attr.save
    
    redirect_to :action=>"list"
  end
  
  def delete_prop
    attr = ProductAttr.find(params[:id])
    conn = ActiveRecord::Base.connection
    conn.drop_table("product_attr_#{params[:id]}")
    attr.destroy
    redirect_to :action => 'list'
  end
  
  def view_prop
    attr = ProductAttr.find(params[:id])
    helper = XMLHelper.new
    helper.ReadFromString(EncodeUtil.change("GB2312", "UTF-8", attr.interface))
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:record=>@apply, :encoding=>"gb2312"})
    render :layout=>"notoolbar_app"
  end
end
