require "active_record"
#require_gem "activerecord"

class Anon < ActiveRecord::Base
end

class ReportDataSource
    def initialize(*args)
        if args.length == 1
            @result = ActiveRecord::Base.find_by_sql(args[0])
        end
        @current_record = -1
    end
    
    def Query(sql)
        #@result = Anon.attributes_before_type_cast()
        @result = Anon.find_by_sql(sql)
    end
    
    def GetRecordCount
        @result.length
    end
    
    def Next
        #print @current_record.to_s + "\n"
        if @current_record < @result.size - 1
            @current_record += 1
            return true
        else
            return false
        end
    end
    
    def id()
        return GetFieldValue("id").to_i
    end
    
    def method_missing(method_id, *args)
        name = method_id.id2name.to_s
        return GetFieldValue(name)
    end
private
    def GetFieldValue(name)
        if @result[@current_record]
            @value = @result[@current_record].attributes_before_type_cast()
            if @value.include?(name)
              result = @value[name]
              if result    
                result.scan(/(\d\d\d\d-\d\d-\d\d) 00:00:00/) 
                result = $1 if $&
              end
              return result.to_s
            end
        end
        return ""
    end
end

#ActiveRecord::Base::establish_connection(
#                :adapter => "mysql",
#                :host => "localhost",
#                :database => "Fuwai",
#                :port => "6807",
#                :username => "root",
#                :encoding => "gb2312",
#                :password => "")