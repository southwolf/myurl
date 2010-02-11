require "test/unit"
require "Table"
require "StyleManager"
require "Diction"
require "iconv"
require "Size"
require "Style"
require "Script"
require 'rexml/document'
require 'win32ole'
require "EncodeUtil"
require "Cell"
require "xmlhelper"

class TestTableLib < Test::Unit::TestCase
    def ttest_xml
    	helper = XMLHelper.new
        
        helper.Ruby_ReadFromXMLFile('d:\param\jxpj.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        
        file = File.new('d:\param\jxpj_ruby2.xml', "wb")
        file.write helper.REXML_WriteToXML(helper.tables, dictFactory, script, params)
        file.close
    
    end
    
    def test_msxml
    	helper = XMLHelper.new
        
        helper.MS_ReadFromXMLFile('d:\param\jxpj.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        
        file = File.new('d:\param\jxpj_ms2.xml', "wb")
        file.write helper.REXML_WriteToXML(helper.tables, dictFactory, script, params)
        file.close
    
    end
end