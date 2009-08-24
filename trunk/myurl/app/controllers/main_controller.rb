require 'net/http'
require 'EncodeUtil.rb'
require 'base64'

class MainController < ApplicationController
  before_filter :login_required, :only=>['myurl']
  
  def index
    @recommands = Recommand.paginate :page=>params[:page], :per_page=>10, :order=>"id desc"
    month = Time.new.months_ago(1)
    @month_recommands = Recommand.find_by_sql("select recommands.*,  count(weburls.id) as c from  recommands left join weburls on recommands.id=weburls.recommand_id where weburls.created_at > '#{month.strftime("%Y-%m-%d")}' group by recommands.id order by c desc limit 10")
    @tags = Tag.find_by_sql("select tags.*, count(tags.id) as c from tags left join recommand_tag on tags.id = recommand_tag.tag_id group by tags.id limit 100")
    @serial = @tags.collect{|t| t["c"].to_i}.sort.reverse
    render :layout=>"main_index"
  end
  
  def myurl 
    if params[:id]      #修改
      @weburl = Weburl.find(params[:id])
      cata_id = @weburl.catalog_id
    else                #新加
      @weburl = Weburl.new
      @weburl.address = params[:url] if params[:url]
      @weburl.desc = params[:title] if params[:title]
      cata_id = params[:cata] || 0
      @weburl.recommand_id = params[:rid] if params[:rid]
    end
    @weburls = Weburl.paginate :page=>params[:page], :per_page=>10, :order=>"id desc", :conditions=>"user_id = #{session[:user].id} and catalog_id=#{cata_id}"
  end
  
  def tag
    @tag = Tag.find(params[:id])
    #@recommands = Recommand.find_by_sql("select * from recommands, recommand_tag where recommands.id = recommand_tag.recommand_id and recommand_tag.tag_id=#{params[:id]}")
    @recommands = Recommand.paginate :page=>params[:page], :per_page=>10, :conditions=>"recommand_tag.tag_id=#{params[:id]}",:joins=>"left join recommand_tag on recommand_tag.recommand_id = id"
  
    month = Time.new.months_ago(1)
    @month_recommands = Recommand.find_by_sql("select recommands.*,  count(weburls.id) as c from  recommands left join weburls on recommands.id=weburls.recommand_id where weburls.created_at > '#{month.strftime("%Y-%m-%d")}' group by recommands.id order by c desc limit 10")
    @tags = Tag.find_by_sql("select tags.*, count(tags.id) as c from tags left join recommand_tag on tags.id = recommand_tag.tag_id group by tags.id limit 100")
    @serial = @tags.collect{|t| t["c"].to_i}.sort.reverse
    render :layout=>"main_index"
  end
  
  def share
    @weburl = Weburl.find(params[:id])
    @pre_tags = Tag.find_by_sql("select *, count(tag_id) c from tags left join recommand_tag on tags.id = recommand_tag.tag_id group by id  order by c desc limit 100")
  end
  
  def create_share
    weburl = Weburl.find(params[:id])
    recommand = Recommand.new
    recommand.address = weburl.address
    recommand.logo = weburl.logo
    recommand.name = weburl.desc
    recommand.user_id = session[:user].id
    recommand.save
    weburl.recommand_id = recommand.id
    weburl.save
    
    recent = Recent.new
    recent.user_id = session[:user].id
    recent.kind = 2
    recent.site_id = recommand.id
    recent.save
    
    for tag in params[:label].split(" ").uniq
      t = Tag.find(:first, :conditions=>"name = '#{tag}'")
      if t
        the_tag = t
      else
        the_tag = Tag.new
        the_tag.name = tag
        the_tag.save
      end
      rt = RecommandTag.new
      rt.recommand_id = recommand.id
      rt.tag_id = the_tag.id
      rt.save
    end
    
    flash[:notice] = "成功分享了一个网站"
    redirect_to :action=>"myurl", :cata=>weburl.catalog_id
  end
  
  def trylogin
    params[:name] = params[:name].delete("\"'<>") if params[:name]
    if !params[:name] ||params[:name].size == 0
      flash[:notice] = "请输入用户名"
      redirect_to :controller=>"main", :action=>'login'
      return
    end
    
    if !params[:password] ||params[:password].size == 0
      flash[:notice] = "请输入密码"
      redirect_to :controller=>"main", :action=>'login'
      return
    end
    
    digest = Digest::MD5.new
    digest << params[:password]
    password = digest.hexdigest
    
    admin = User.find(:first, :conditions=>"name='#{params[:name]}'")
    if !admin 
      flash[:notice] = "对不起，没有这个用户" + params[:name]
      redirect_to :controller=>"main", :action=>'login'
      return
    end
    
    admin = User.find(:first, :conditions=>"name='#{params[:name]}' and password='#{password}'")
    if !admin
      flash[:notice] = "对不起，密码错误"
      
      redirect_to :controller=>"main", :action=>'login'
    else
      session[:user] = admin
      flash[:notice] = "欢迎您回来:" + admin.name
      cookies[:name] = {:value=>params[:name], :expires=>300.days.from_now}
      redirect_to_stored
    end
  end
  
  def get_web_title
    begin
      url = params[:url]
      url = "http://" + url if url.scan(/http:\/\//i).size == 0
      url.delete!(' ')
      p url
      @body = ''
      begin
        Timeout::timeout(30) do |l|
          response = Net::HTTP.get_response(URI.parse(url))
          response.body[0, 200]
          @body = response.body
        end
      rescue Exception => e
        p e
        render :layout=>false
        return
      end
      
      
      @body.scan(/<title>(.*)<\/title>/i)
      @title = $1.to_utf8
      
      begin
        @body.scan(/<link .* type=["']image\/x-icon["'].*>/)
        @logo = $&
        @logo.scan(/href.*=.*["']([\w\.\/:\\\&\+=%]*)["']/)
        @logo = $1
        if !@logo.index("http")
          @logo = params[:url] + @logo
          @logo.gsub("\/\/", "/")
        end
        p @logo
      rescue Exception=>e
         p e
      end
    rescue Exception=>err
      p err
      p e.backtrace
    end
    
   
    render :layout=>false
  end
  
  def remote_dir_post
    begin
      name = Base64.decode64(params[:name])
      parent = Base64.decode64(params[:parent]) if params[:parent]
      user = User.find(params[:id])
      label = Catalog.find(:first, :conditions=>"name='#{name}'")
      if !label
        catalog = Catalog.new
        catalog.name = name.to_utf8
        catalog.user_id = user.id
        if parent
          p_cata = Catalog.find(:first, :conditions=>"name='#{parent}'")
          catalog.parent_id = p_cata.id if p_cata
        end
        catalog.save
      end
     rescue Exception=>e
      p e
     end

    render :text=>"1"
  end
  
  def remote_post
    begin
    user = User.find(params[:id])
    url = Weburl.find(:first, :conditions=>"address='#{Base64.decode64(params[:url])}' and user_id = #{user.id}")
    if !url
      url = Weburl.new
      url.user_id = user.id
      url.address = Base64.decode64(params[:url])
      url.desc = params[:name].to_utf8
      url.logo = Base64.decode64(params[:logo]) if params[:logo] && params[:logo].size > 0
      url.catalog_id = 0
      if params[:catalog] && params[:catalog].size > 0
         catalog = Catalog.find(:first, :conditions=>"user_id = #{user.id} and name='#{Base64.decode64(params[:catalog]).to_utf8}'")
         if catalog
          url.catalog_id = catalog.id
         end
      end
      url.save
    end
    rescue Exception => err
      p err
      p err.backtrace
    end
    
    render :text=>"1"
  end
end
