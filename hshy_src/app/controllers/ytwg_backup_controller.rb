class YtwgBackupController < ApplicationController   
  def createbak
    `mysqldump -uroot -r tmp/data.bak --default-character-set=gb2312 --database hshy`
    
    dfile = File.open("tmp/data.bak", "rb")
    f = File.open('tmp/data.gzip', 'wb')
    gz = Zlib::GzipWriter.new(f)
    gz.write EncodeUtil.change("GB2312", "UTF-8", dfile.read)
    gz.close
    dfile.close
    send_file 'tmp/data.gzip', :filename=>"#{Time.new.strftime('%Y-%m-%d')}data.bak"
  end
  
  def restorebak
#    stream = params[:data]
#    content = stream.read
#    file = File.new("tmp/#{Time.new().strftime('%Y-%m-%d')}.tmp.zip", 'wb')
#    file << content
#    file.close
#
#    tt = File.new("tmp/#{Time.new().strftime('%Y-%m-%d')}.tmp.zip", 'rb')
    
#    file = File.new("tmp/#{Time.new().strftime('%Y-%m-%d')}.tmp.zip", 'rb')
    gz = Zlib::GzipReader.new(params[:data])
    stream = gz.read
#    file.close    
    
#    tt.close
    
    file = File.new("tmp/#{Time.new().strftime('%Y-%m-%d')}.res", 'wb')
    file << stream
    file.close
    
    `mysql -uroot -e"source tmp/#{Time.new().strftime('%Y-%m-%d')}.res`
    flash[:notice] = '数据恢复完成'
    redirect_to :action=>'restore'
  end
end
