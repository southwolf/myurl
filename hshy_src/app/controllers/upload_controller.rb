class UploadController < ApplicationController
  def index
    list
    #render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @signs = Sign.find(:all, :conditions=>"userid=#{session[:user].id}")
    if @signs.size>0
      @sign_id = params[:sign_id]
      if @sign_id && @sign_id != '-1'
        @upload_pages, @uploads = paginate :uploads, :per_page => 10, :conditions=>"outid=#{@sign_id}", :order=>params[:order]
      else
        ids = []
        for sign in @signs
          ids << sign['id']
        end
        @upload_pages, @uploads = paginate :uploads, :per_page => 10, :conditions=>"outid in (#{ids.join(',')})", :order=>params[:order]
      end
      @sign_id = -1 if !@sign_id
      
      #@upload_pages, @uploads = paginate :uploads, :per_page => 10, :conditions=>"outid=#{@sign.id}"
    else
      @upload_pages, @uploads = paginate :uploads, :per_page => 10, :conditions=>"outid=-1"
    end
    render :action => 'list'
  end
  
  def list_all
    @upload_pages, @uploads = paginate :uploads, :per_page => 10
  end

  def show
    @upload = Upload.find(params[:id])
    helper = $Templates['经营情况表']    
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
    		{:readonly=>true, :record=>@upload})
    		
  end

  def new
    @upload = Upload.new
    @signs = Sign.find(:all, :conditions=>"userid=#{session[:user].id}")
    
    @upload.outid = params[:id]
    helper = $Templates['经营情况表']    
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
    		{:only_table_tag=>true, :record=>@upload})
    		
  end

  def create
    @sign = Sign.find(:all, :conditions=>"userid=#{session[:user].id}")[0] rescue nil
    if !@sign
      flash[:error]="没有登记证，不能填数"
      redirect_to :action => 'new', :id => '-1'
      return
    end
    
    exists = Upload.find(:all, :conditions=>"outid=#{params[:UPLOAD][:outid]} and timeid=#{params[:UPLOAD][:timeid]}")
    if exists.size > 0
      flash[:error] = '该单位已经填写了该期数据，不可重复填报'
      redirect_to :action => 'new', :id => params[:UPLOAD][:outid]
      return
    end
    
    @upload = Upload.new(params[:UPLOAD])
    if @upload.outid.to_s == '-1'
      flash[:error] = '没有选择登记证，上报失败'
      redirect_to :action => 'new', :id =>'-1'
      return
    end
    
    @upload.uploadman = session[:user].truename
    @upload.uploadtime = Time.new
    if @upload.save
      flash[:notice] = '上报数据成功.'
      redirect_to :action => 'list'
    else
      redirect_to :action => 'new', :id => '-1'
    end
  end

  def edit
    @upload = Upload.find(params[:id])
    
    @signs = Sign.find(:all, :conditions=>"userid=#{session[:user].id}")
    helper = $Templates['经营情况表']    
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
    		{ :record=>@upload})
  end

  def update
    @upload = Upload.find(params[:id])
    if @upload.update_attributes(params[:UPLOAD])
      flash[:notice] = '修改上报数据成功.'
      redirect_to :action => 'list', :id => @upload
    else
      render :action => 'edit'
    end
  end

  def destroy
    Upload.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def query
    @upload = Upload.new
  end
  
  def result
    condition = "timeid = #{params[:timeid]} "
    t = Array.new
    if params[:unitname] && params[:unitname].size > 0
      signs = Sign.find(:all, :conditions=>"A2 like '%#{params[:unitname]}%'")
      for sign in signs
        t << sign.id
      end
      sel = t.join(',')
      condition += "and outid in ('#{sel}')"
    end
    
    @upload_pages, @uploads = paginate :uploads, :per_page => 10, :conditions=>condition
    render :action => 'list_all'      
  end
  
  def timelist
    @ytwg_dtime_pages, @ytwg_dtimes = paginate :ytwg_dtimes, :per_page => 10
  end
  
  def sum
    @upload = Upload.find_by_sql("select sum(A1) as A1,sum(A2) as A2,sum(A3) as A3, 
                sum(B1) as B1,sum(B2) as B2,sum(B3) as B3,
                sum(C1) as C1,sum(C2) as C2,sum(C3) as C3
                from upload where timeid=#{params[:id]}")[0]
                
    helper = $Templates['经营情况表']
    
    @style = helper.StyleToHTML(helper.tables[0])
    @html = helper.TableToEditHTML(helper.tables[0], helper.dictionFactory, 
    		{:encoding=>"utf-8", :only_table_tag=>true, :readonly=>true, :record=>@upload})
  end
  
  def exportsum
    @upload = Upload.find_by_sql("select sum(A1) as A1,sum(A2) as A2,sum(A3) as A3, 
                sum(B1) as B1,sum(B2) as B2,sum(B3) as B3,
                sum(C1) as C1,sum(C2) as C2,sum(C3) as C3
                from upload where timeid=#{params[:id]}")[0]
                
    helper = $Templates['经营情况表']
    set_table_data(helper.tables[0], @upload)
    send_file helper.ExportToExcel([helper.tables[0]], helper.dictionFactory), :filename =>('sum' + params[:id].to_s) + ".xls"
  end
  
end
