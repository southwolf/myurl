class AdminController < ApplicationController
  def welcome
    render :layout=>'application'
  end
  
  def index
    @user = YtwgUser.find(session[:user].id)
  end
end