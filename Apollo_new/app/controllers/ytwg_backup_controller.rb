class YtwgBackupController < ApplicationController   
  upload_status_for  :restorebak
	
  def createbak
    `#{$Back_Command}`
    
    f_sql = File.new('tmp/data.bak')
    f = open('tmp/data.zip', 'wb')
    gz = Zlib::GzipWriter.new(f)
    gz.write f_sql.read()
    f_sql.close
    gz.close
    
    File.delete('tmp/data.bak')
    
    send_file 'tmp/data.zip', :filename=>"#{Time.new.strftime('%Y-%m-%d')}data.bak"
  end
  
  
  def restorebak
    stream = params[:data]
    content = stream.read
    file = File.new("tmp/data.zip", 'wb')
    file << content
    file.close

    
    file = File.new('tmp/data.bak', 'w')
    Zlib::GzipReader.open('tmp/data.zip') {|gz|
      file << gz.read
    }
    file.close
    
    `#{$Restore_Command}`
    flash[:notice] = '数据恢复完成'
    
    #p 'fuck'
    redirect_to :action=>'restore'
  end
end
