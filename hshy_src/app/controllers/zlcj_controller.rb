class ZlcjController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @zlcjs = Zlcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def show
    @zlcj = Zlcj.find(params[:id])
    
    helper = $Templates['租赁业务单笔成交报告']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script, :record=>@zlcj})
  end

  def new
    helper = $Templates['租赁业务单笔成交报告']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script})
    @tableid = helper.tables[0].GetTableID()
  end

  def create
    @zlcj = Zlcj.new(params[:ZLCJ])
    @zlcj.status = 0
    @zlcj.inputtime = Time.new
    @zlcj.inputer = session[:user].id
    if @zlcj.save
      flash[:notice] = '创建租赁业务单笔成交报告成功'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @zlcj = Zlcj.find(params[:id])
    
    helper = $Templates['租赁业务单笔成交报告']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script, :record=>@zlcj})
    @tableid = helper.tables[0].GetTableID()
  end

  def update
    @zlcj = Zlcj.find(params[:id])
    if @zlcj.update_attributes(params[:ZLCJ])
      flash[:notice] = '修改租赁成交报告成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy    
    cj = Zlcj.find(params[:id])
    cj.destroy
    redirect_to :action => 'list'
      
    return

    if cj.inputer == session[:user].id
      cj.destroy
      redirect_to :action => 'list'
    else
      flash[:notice] = '只能删除自己创建的成交报告.'
      redirect_to :action => 'list'
    end      
  end
  
  def attention
    @attention_zj = Zlcj.find(:all, :conditions=>"g5> '#{Time.new.strftime('%Y-%m-%d')}' and g5 < '#{Time.new.months_ago(-1).strftime('%Y-%m-%d')}'")
  end
end
