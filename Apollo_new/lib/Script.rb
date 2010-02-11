require "date"
require "rexml/document"

include REXML

class CTaskScript
    
    def initialize()
        @name = ""
        @m_timeModified = Date.new
        @m_scriptOutsideAudit = ""
        @m_scriptOutsideCalc = ""
        @m_scriptTableCalc = Hash.new
        @m_scriptTableAudit = Hash.new
        @m_sCommonScript = ""
        @m_arTableSequence = ""
    end
    
    def getName
        @name
    end
    
    def GetTimeModified
        @m_timeModified
    end
    
    def getAuditScript(key)
        return @m_scriptOutsideAudit if key == ""
        return @m_scriptTableAudit[key] || ""
    end
    
    def getCalcScript(key)
        return @m_scriptOutsideCalc if key == ""
        return @m_scriptTableCalc[key] || ""
    end
    
    def getCalcSequence
        return @m_arTableSequence
    end
    
    def getCommonScript
        @m_sCommonScript
    end
    
    def setName(value)
        @name = value
    end
    
    def setTimeModified(time)
       @m_timeModified = time.dup()
    end
    
    def setAuditScript(key, value)
        if key == ""
            @m_scriptOutsideAudit = value||""
        else
            @m_scriptTableAudit[key] = value||""
        end
    end
    
    def setCalcScript(key, value)
        if key == ""
            @m_scriptOutsideCalc = value||""
        else
            @m_scriptTableCalc[key] = value||""
        end
    end
    
    def setCalcSequence(sequence)
        @m_arTableSequence = sequence
    end
    
    def setCommonScript(script)
        @m_sCommonScript = script
    end
    
    #根据传入的xml字符串生成对象
    #这个传入的xml字符串来源于任务设计器导出的xml文件。不是表xml文件中的部分
    def parse(text)
        doc = Document.new(text)

        setName(doc.root.attributes['name']);
        
        doc.each_element('/scriptSuit/common'){|element|
          setCommonScript(element.text)
        }
        
        doc.each_element('/scriptSuit/calculateCrossTable'){|element|
          setCalcScript("", element.text)
        }
        
        doc.each_element('/scriptSuit/auditCrossTable'){|element|
          setAuditScript("", element.text)
        }
        
        doc.each_element('/scriptSuit/calculateInTable'){|element|
          setCalcScript(element.attributes['name'], element.text)
        }
        
        doc.each_element('/scriptSuit/auditInTable'){|element|
          setAuditScript(element.attributes['name'], element.text)
        }
        
        doc.each_element('/scriptSuit/sequence'){|element|
          setCalcSequence(element.text)
        }
    end
    
    def OutputXML(node)
        node.add_attributes({'CalcSequence' => @m_arTableSequence})
        
        scriptnode1 = node.add_element(Element.new('Script'))
        scriptnode1.add_attributes({'Language'=>"0", 'TableID'=>"", 'Type'=>"4"})
        scriptnode1.text=@m_sCommonScript
        
        scriptnode2 = node.add_element(Element.new('Script'))
        scriptnode2.add_attributes({'Language'=>"0", 'TableID'=>"", 'Type'=>"2"})
        scriptnode2.text = @m_scriptOutsideCalc
        
        scriptnode3 = node.add_element(Element.new('Script'))
        scriptnode3.add_attributes({'Language'=>"0", 'TableID'=>"", 'Type'=>"3"})
        scriptnode3.text = @m_scriptOutsideAudit
        
        @m_scriptTableCalc.each { |key, value|
            # "write script"
            scriptnode4 = node.add_element(Element.new('Script'))
            scriptnode4.add_attributes({'Language'=>"0", 'TableID'=>key, 'Type'=>"0"})
            scriptnode4.text = value
        }
        
        @m_scriptTableAudit.each { |key, value|
            scriptnode4 = node.add_element(Element.new('Script'))
            scriptnode4.add_attributes({'Language'=>"0", 'TableID'=>key, 'Type'=>"1"})
            scriptnode4.text = value
        }
    end
end
