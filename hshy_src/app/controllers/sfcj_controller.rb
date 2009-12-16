class SfcjController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #刚提交的
    @sfcj1 = Sfcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"status = 0"
    
    #会计审核过的
    @sfcj2 = Sfcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"status = 1"
    
    #存档的
    @sfcj3 = Sfcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"status = 2"
  end

  def show
    @sfcj = Sfcj.find(params[:id])
    
    helper = $Templates['售房业务单笔成交报告']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script, :record=>@sfcj})
    @tableid = helper.tables[0].GetTableID()
  end

  def new
    @sfcj = Sfcj.new
    
    helper = $Templates['售房业务单笔成交报告']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script})
    @tableid = helper.tables[0].GetTableID()
  end

  def create
    @sfcj = Sfcj.new(params[:SFYW])
    @sfcj.status = 0
    @sfcj.inputtime = Time.new
    @sfcj.inputer = session[:user].id
    if @sfcj.save
      flash[:notice] = '创建售房业务单笔成交报告成功.'
      news = YtwgNews.new
      news.title = "恭喜#{@sfcj.e15} #{@sfcj.e16}成功售出房屋一套"
      news.content = "签约时间:#{@sfcj.e15},签约金额:#{@sfcj.a12}元,房屋地址:#{@sfcj.a1}"
      news.publish_time = Time.new
      news.user_id = session[:user].id
      news.save
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @sfcj = Sfcj.find(params[:id])
    
    helper = $Templates['售房业务单笔成交报告']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script, :record=>@sfcj})
    @tableid = helper.tables[0].GetTableID()  end

  def update
    @sfcj = Sfcj.find(params[:id])
    if @sfcj.update_attributes(params[:SFYW])
      flash[:notice] = '修改售房成交报告成功'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    cj = Sfcj.find(params[:id])
    cj.destroy
    redirect_to :action => 'list'
  end
  
  def tip
    cj = Sfcj.find(params[:id])
    cj.status = params[:status]
    cj.save
    flash[:notice] = "售房成交报告审核成功"
    redirect_to :action=>"list"
  end
end
