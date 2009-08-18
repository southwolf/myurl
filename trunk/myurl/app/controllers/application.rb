# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_myurl_session_id'
  include SimpleCaptcha::ControllerHelpers 
  
  before_filter :check_cookie
  
  def check_cookie
    if cookies[:name] && !session[:user]
      user = User.find(:first, :conditions=>"name = '#{cookies[:name]}'")
      session[:user] = user
    end
  end
  
  def admin_required
    if session[:user]
      if session[:user].id == 1
        return true;
      end
    end
    render :text=>"对不起，你不是管理员"
    return false 
  end
  
  def login_required
    if session[:user]
      return true
    end
    flash[:flash]='请先登陆'
    session[:return_to]=request.request_uri
    redirect_to :controller => "main", :action => "login"
    return false 
  end
  
  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to_url(return_to)
    else
      redirect_to :controller=>"main", :action=>'myurl'
    end
  end
end
