require 'iconv'

def dumpfile(text, path)
	file = File.new(path, "w")
	file << text
	file.close
end

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

def timestr_to_time(str)
	result = 0
	if str.scan(/(\d+)分/).size > 0
		result += $1.to_i * 60
	end
	
	if str.scan(/(\d+)小时/).size > 0
		result += $1.to_i * 60 * 60
	end
	
	if str.scan(/(\d+)天/).size > 0
		result += $1.to_i * 60 * 60 * 24
	end
	Time.new + result
end