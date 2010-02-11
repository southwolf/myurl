require "test/unit"
require "LogFont"
require "Size"
require "YtLog"
require "Cell"
require "Style"
require "StyleManager"
require "Diction"
require "ZmRC"
require "Script"
require "Table"
require "XMLHelper"
require "rexml/document"
require "time"
require "win32ole"
require "ReportDataSource"
require "ReportEngine"

class Keshi < ActiveRecord::Base
end

class TestTableLib < Test::Unit::TestCase
    
    
    def test_report_engine
    	$Debug_On = true
    	
        print "begin report: #{Time.new} \n" 
        helper = XMLHelper.new
        
        helper.MS_ReadFromXMLFile('d:\param\rmrb.template')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        engine = ReportEngine.new()
        
      yttable = helper.tables[0]
      field_sql = extract_field_sql(yttable)
		
		ActiveRecord::Base::establish_connection(
                :adapter => "mysql",
                :host => "localhost",
                :database => "apollo_rmrb",
                :port => "3306",
                :username => "root",
                :encoding => "utf8",
                :password => "")
                
        p ActiveRecord::Base.defined_connections
        
        file = File.new('d:\a.txt')
        other_sql =file.read
        file.close
        p "select #{field_sql} #{other_sql}"
        tables[0] = engine.fill(tables[0], "select #{field_sql} #{other_sql}", script);
        

        file = File.new('d:\param\rmrb.html', "wb")
        helper = XMLHelper.new
        #file.write helper.REXML_WriteToXML(tables, dictFactory, script, params)
        file.write helper.TableToEditHTML(tables[0], dictFactory, {:onlyTableTag => false, :title => "hello", :page => 2, :readonly=>true, :linesperpage => 20, :showallpage => true})
        file.close
        
        print "end report: #{Time.new} \n" 
    end
    

    def extract_field_sql(yttable)
    	fields = []
    	Integer(0).upto(yttable.GetRowCount()-1) do |row|
        next if yttable.IsEmptyRow(row)
        Integer(0).upto(yttable.GetColumnCount()-1) do |col|
          next if yttable.IsEmptyCol(col)
          cell = yttable.GetCell(row, col)
          next if !cell.IsStore()
          newtext = cell.GetText().gsub(/(\w*)\[(\w*)\]/) {|s|
          	fields << s.gsub(/(\w*)\[(\w*)\]/, '\1.\2 as \1_\2')
          }
          newtext = cell.GetText().gsub(/(\w*)\[(\w*)\]/, '\1_\2')
          cell.SetText(newtext.downcase)
        end
      end
      fields.uniq!      
      
      fields.join(',').downcase
      
    end
end

