class KaoqinController < ApplicationController
  def index
    @user = YtwgUser.find(params[:user] || session[:user].id)    
    @now = Time.new
    @from = @now.beginning_of_month
    @logs = Daka.find(:all, 
      :conditions=>"ticktime>'#{@from.to_formatted_s(:db)}' and ticktime < '#{@now.to_formatted_s(:db)}' and user_id = '#{@user.id}' ",
      :order=>"id")
  end
end
