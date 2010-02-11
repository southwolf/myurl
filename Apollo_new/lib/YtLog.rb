class YtLog
  class << self
    def info(object, title=nil)
      if $Debug_On
        if object.is_a?(String)
          if title
            print EncodeUtil.change("GBK", "UTF-8", "Debug: " + title + ": "+ object + "\n")
          else
            print EncodeUtil.change("GBK", "UTF-8", "Debug: " + object + "\n")
          end
        else
          if title
            print EncodeUtil.change("GBK", "UTF-8", "Debug: " + title + ": ")
          else
            print EncodeUtil.change("GBK", "UTF-8",  "Debug: " + " ")
          end
          if object.is_a?(Time)
            p object.strftime("%Y-%m-%d %H:%M:%S")
          else
            p EncodeUtil.change("GBK", "UTF-8", object.to_s)
          end
          
        end
      end
    end
  end
end