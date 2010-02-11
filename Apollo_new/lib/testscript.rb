require "test/unit"
require "rexml/document"
require "Script"

class TestScript < Test::Unit::TestCase
    def test_parse
        taskscript = CTaskScript.new
        file = File.new('d:\param\fa1.xml', 'r')
        text = file.read()
        taskscript.parse(text)
    end
end