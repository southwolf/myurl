require 'net/http'
require 'EncodeUtil.rb'

class MainController < ApplicationController
  before_filter :login_required, :only=>['myurl']
  
  def index
    @recommands = Recommand.paginate :page=>params[:page], :per_page=>10, :order=>"id desc"
    render :layout=>"main_index"
  end
  
  def myurl
    if params[:id]      #修改
      @weburl = Weburl.find(params[:id])
      cata_id = @weburl.catalog_id
    else                #新加
      @weburl = Weburl.new
      @weburl.address = params[:url] if params[:url]
      cata_id = params[:cata] || 0
      @weburl.recommand_id = params[:rid] if params[:rid]
    end
    @weburls = Weburl.paginate :page=>params[:page], :per_page=>10, :order=>"id desc", :conditions=>"user_id = #{session[:user].id} and catalog_id=#{cata_id}"
  end
  
  def share
    @weburl = Weburl.find(params[:id])
    @pre_tags = Tag.find_by_sql("select *, count(tag_id) c from tags left join recommand_tag on tags.id = recommand_tag.tag_id group by id  order by c desc limit 20")
  end
  
  def create_share
    weburl = Weburl.find(params[:id])
    recommand = Recommand.new
    recommand.address = weburl.address
    recommand.name = weburl.desc
    recommand.save
    weburl.recommand_id = recommand.id
    weburl.save
    
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
    redirect_to :action=>"myurl", :id=>params[:id]
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
      response = Net::HTTP.get_response(URI.parse(params[:url]))
      body = response.body.to_gb2312
      body.scan(/<title>(.*)<\/title>/i)
      @title = $1.to_utf8
      p @title
      
      begin
        body.scan(/<link .* type=["']image\/x-icon["'].*>/)
        @logo = $&
        @logo.scan(/href.*=.*["']([\w\.\/:\\\&\+=%]*)["']/)
        @logo = $1
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
end
