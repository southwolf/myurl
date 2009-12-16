class MigratemanagerController < ApplicationController
  def index
    @migrations = Array.new
    dir = Dir.open('.\db\migrate')
    begin
      dir.each { |item|
        @migrations<<item if item!='.' && item !='..'
      }
    ensure
      dir.close
    end
  end
  
  #新建migrate
  def create
    `ruby script/generate migration #{params[:name]}`
    flash[:notice] = "新建#{params[:name]}文件成功"
    redirect_to :action=>"index"
  end
  
  #编辑migrate
  def edit
    file = File.open(".\\db\\migrate\\#{params[:name]}", "r")
    @data = file.read
    file.close
  end
  
  def delete
    File.delete(".\\db\\migrate\\#{params[:name]}")
    flash[:notice] = "删除#{params[:name]}文件成功"
    redirect_to :action=>"index"
  end
  
  def update
    file = File.open(".\\db\\migrate\\#{params[:name]}", "w")
    file.write params[:data]
    file.close
    flash[:notice] = "修改#{params[:name]}文件成功"
    redirect_to :action=>"index"
  end
  
  def execute
    `rake db:migrate VERSION=#{params[:name].to_i}`
    flash[:notice] = "执行完毕"
    redirect_to :action=>"index"
  end
end
