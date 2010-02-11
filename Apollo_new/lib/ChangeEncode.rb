class EncodeUtil
    class << self
        def change(to, from, str)
            strArray = Iconv.iconv(to, from, str)
                result = ''
                for char in strArray
                     result += char
                end
            result
        end
    end
end
