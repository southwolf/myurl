class SfcjController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #���ύ��
    @sfcj1 = Sfcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"status = 0"
    
    #�����˹���
    @sfcj2 = Sfcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"status = 1"
    
    #�浵��
    @sfcj3 = Sfcj.paginate :page=>params[:page], :per_page => 20, :order=>"id desc", :conditions=>"status = 2"
  end

  def show
    @sfcj = Sfcj.find(params[:id])
    
    helper = $Templates['�۷�ҵ�񵥱ʳɽ�����']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script, :record=>@sfcj})
    @tableid = helper.tables[0].GetTableID()
  end

  def new
    @sfcj = Sfcj.new
    
    helper = $Templates['�۷�ҵ�񵥱ʳɽ�����']
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
      flash[:notice] = '�����۷�ҵ�񵥱ʳɽ�����ɹ�.'
      news = YtwgNews.new
      news.title = "��ϲ#{@sfcj.e15} #{@sfcj.e16}�ɹ��۳�����һ��"
      news.content = "ǩԼʱ��:#{@sfcj.e15},ǩԼ���:#{@sfcj.a12}Ԫ,���ݵ�ַ:#{@sfcj.a1}"
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
    
    helper = $Templates['�۷�ҵ�񵥱ʳɽ�����']
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
      {:encoding=>"gb2312", :script=>helper.script, :record=>@sfcj})
    @tableid = helper.tables[0].GetTableID()  end

  def update
    @sfcj = Sfcj.find(params[:id])
    if @sfcj.update_attributes(params[:SFYW])
      flash[:notice] = '�޸��۷��ɽ�����ɹ�'
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
    flash[:notice] = "�۷��ɽ�������˳ɹ�"
    redirect_to :action=>"list"
  end
end
