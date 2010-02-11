class FileController < ApplicationController
  def index
    @dir = params[:dir] || '.'
    @files = Hash.new    
    @current_dir = params[:current_dir] + "/" + (params[:dir]||'') if params[:current_dir]
    @current_dir = Dir.pwd if !@current_dir
    dir = Dir.open(@current_dir)
    begin
      dir.each { |item|
        @files[item] = @current_dir + "/" +item if item!='.'
      }
    ensure
      dir.close
    end
  end
  
  def edit
    file = File.open("#{params[:current_dir]}/#{params[:name]}", "r")
    @data = file.read
    file.close
  end
  
  #保存
  def update
    file = File.open("#{params[:current_dir]}/#{params[:name]}", "w")
    file.write params[:data]
    file.close
    flash[:notice] = "修改#{params[:name]}文件成功"
    redirect_to :action=>"index", :current_dir => params[:current_dir]
  end
  
  #删除
  def delete
    File.delete("#{params[:current_dir]}/#{params[:name]}")
    flash[:notice] = "删除#{params[:name]}文件成功"
    redirect_to :action=>"index"
  end

end
