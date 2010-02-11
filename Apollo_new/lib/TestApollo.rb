require "test/unit"
require "XMLHelper"

class TestTableLib < Test::Unit::TestCase
   def test_script
        helper = XMLHelper.new
        helper.MS_ReadFromXMLFile('d:\param\query.xml')
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        dictionFactory = helper.dictionFactory
        
        
        #file = File.new('d:\param\dx_ruby.xml', "wb")
        #file.write helper.REXML_WriteToXML(tables, dictionFactory, script, params)
        #file.close
        #tables[0].SetCellValue(14, 5, 100)
        
        #print helper.ExecuteCalc("QYJT")
        
        #helper.InitScriptEngine()
        
        file = File.new('d:\param\query_ruby.html', "wb")
        file<< helper.TableToEditHTML(helper.tables[0], dictionFactory,{})
        file.close
   end
    
end