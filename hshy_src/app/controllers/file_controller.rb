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
  
  #����
  def update
    file = File.open("#{params[:current_dir]}/#{params[:name]}", "w")
    file.write params[:data]
    file.close
    flash[:notice] = "�޸�#{params[:name]}�ļ��ɹ�"
    redirect_to :action=>"index", :current_dir => params[:current_dir]
  end
  
  #ɾ��
  def delete
    File.delete("#{params[:current_dir]}/#{params[:name]}")
    flash[:notice] = "ɾ��#{params[:name]}�ļ��ɹ�"
    redirect_to :action=>"index"
  end

end
