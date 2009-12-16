require "iconv"
class EncodeUtil
    class << self
        def change(to, from, str)
          begin  
          strArray = Iconv.iconv(to, from, str)
                result = ''
                for char in strArray
                     result += char
                end
            result
          rescue 
            str
          end
        end
    end
end
