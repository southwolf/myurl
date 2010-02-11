require "test/unit"
require "LogFont"
require "Size"
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
    def test_LogFont
        a = LogFont.new
        b = LogFont.new
        a.Size=9
        a.FontName='宋体'
        b.Size=9
        b.FontName='宋体'
        assert_equal(a==b, true)
        
        c = a.dup
        c.Size = 8
        assert_equal(a.Size>c.Size, true)
    end
    
    def test_Size
        rect = CRect.new(1,2,3,4)
        assert_equal(rect.left, 1)
        rect.right += 4
        assert_equal(rect.right, 7)
        
        size = CSize.new(5, 10)
        assert_equal(size.cx, 5)
        size.cx += 3
        assert_equal(size.cx, 8)
    end
    
    def test_cell
        #assert_equal("a">"b", true)
        ["a", "b"].include?("a")
    end
    
    def test_style
        assert_equal(CellStyle::ItRadioBox, 3)
        assert_equal(CellStyle::DT_RIGHT, 0x00000002)
        
        a = CellStyle.new
        a.m_nID = 10
        b = CellStyle.new
        b.m_nID = 20
        assert_equal(a, b)
        a.m_bWrapText = true
        b.m_bWrapText = false
        assert_equal(a!=b, true)
    end
    
    def test_styleManager
        a=StyleManager.new
        a.NewStyle(CellStyle.new, 10)
        a.NewStyle(CellStyle.new, 20)
        a.NewStyle(CellStyle.new, 30)
        a.NewStyle(CellStyle.new, 20)
        assert_equal(a.m_Styles.length, 1)
    end
    
    def test_diction
        factory = DictionFactory.new
        diction = factory.CreateDiction
        factory.AddDiction(diction)
        assert_equal(diction.Length, 1)
        diction.Length = 3
        diction.AddDictItem('001', 'china')
        diction.AddDictItem('002', 'india')
        diction.AddDictItems({'003' =>'USA', '004' => 'Japan', '002'=>'Germany'})
        assert_equal(diction.GetAllItems().length, 4)
        assert_equal(diction.GetItemName('002'), 'Germany')
        assert_equal(factory.GetAllDictions.length, 1)
    end
    
    def test_ZmRC
        zmArray = ZmRCArray.new
        zmArray.Init(10, 2)
        assert_equal(zmArray.GetOrder(8), 7)
        zmArray.InsertAt(3, true)
        assert_equal(zmArray.GetOrder(8), 6)
        zmArray.InsertAt(2, false)
        assert_equal(zmArray.GetOrder(8), 6)
    end
    
    def test_table
        table = CTable.new(StyleManager.new, "table1", "财务表")
        table.OnNewTable(10, 10, 2, 2)
        table.SetCellValue(2,2,"hello")
        table1 = table.dup
        table1.SetCellValue(2, 2, "lmx")
        #print table.GetCellValue(2, 2) + "\n"
        assert_equal(table.GetCellValue(2, 2), table1.GetCellValue(2, 2))
    end
    
    def test_script
        script = CTaskScript.new
        assert_equal(script.getAuditScript(""), "")
    end
    
    def test_table_to_table
        helper = XMLHelper.new
        
        helper.MS_ReadFromXMLFile('d:\param\kb.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        
        table = helper.tables[1]
        table.instance_eval("print cells[1,3]=10")
        table.instance_eval("print cells[1,4]=20")
        print "\n"
        table.instance_eval("print a1 = b1 + c1")
        print "\n"
        
        file = File.new('d:\param\kb_ruby.xml', "wb")
        file.write helper.REXML_WriteToXML(helper.tables, dictFactory, script, params)
        file.close
    end

    def test_table_to_table2
        helper = XMLHelper.new
        
        helper.Ruby_ReadFromXMLFile('d:\param\kb.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        
        file = File.new('d:\param\kb_ruby2.xml', "wb")
        file.write helper.REXML_WriteToXML(helper.tables, dictFactory, script, params)
        file.close
    end
    #def test_TableToXML
    #    table = CTable.new(StyleManager.new, "table1", "财务表")
    #    table.OnNewTable(10, 10, 2, 2)
    #    assert_equal(table.GetMaxDataRow, 10)
    #    assert_equal(table.GetRowCount, 12)
    #    assert_equal(table.GetColumnCount, 12)
    #    table.ClearDataArea()
    #    table.SetCellValue(6, 6, "lmx")
    #    assert_equal(table.GetCellValue(6, 6), "lmx")
    #    
    #    table2 = CTable.new(StyleManager.new, "table2", "table2")
    #    table2.Copy(table)
    #    assert_equal(table2.GetTableID, "table1")
    #    assert_equal(table2.GetRowCount, 12)
    #    assert_equal(table2.m_lRowHeight.length, 12)
    #    
    #    table3 = table.dup
    #    assert_equal(table3.m_lRowHeight.length, 12)
    #    #print table.hash.to_s + " " + table.object_id.to_s + "\n"
    #    #print table3.hash.to_s + " " + table3.object_id.to_s
    #    
    #    table.SetCellProperty({StyleManager::PROP_fieldName => 'lmx'}, 5, 5)
    #    table.SetCellProperty({StyleManager::PROP_wordWrap => 'true', StyleManager::PROP_length => '10'}, CRect.new(3, 1, 8, 4))
    #    table2.SetCellProperty({StyleManager::PROP_varText => 'true'}, 4, 6)
    #    assert_equal(table.GetCell(2, 5).GetTextWidth(), 10)
    #    
    #    table2.OnNewTable(4,4,1,2)
    #    tables = Array.new
    #    
    #    
    #    table4 = CTable.new(StyleManager.new, "table4", "财务表")
    #    table4.OnNewTable(3, 3, 2, 2)        
    #    tables<<table4
    #    tables<<table2
    #    tables<<table3
    #    tables<<table
    #    dictFactory = DictionFactory.new()
    #    script = CTaskScript.new
    #    prop = Hash.new
    #    prop["name"] = "lmx"
    #    prop["age"]  = "2323"
    #    print "开始" + Time.new().to_s + "\n"
    #    file = File.new("c:\\ra.xml", "wb")
    #    helper = XMLHelper.new
    #    file.write helper.REXML_WriteToXML(tables, dictFactory, script, prop)
    #    file.close
    #    print "结束" + Time.new().to_s + "\n"
    #end

    #def test_XMLToTable
    #    print "开始" + Time.new().to_s + "\n"
    #    #REXML::Document.new File.new('d:\param\3_control.xml')
    #    #print "结束" + Time.new().to_s + "\n"
    #    helper = XMLHelper.new
    #    
    #    helper.MS_ReadFromXMLFile('d:\param\a.xml')
    #    dictFactory = helper.dictionFactory
    #    params = helper.parameters
    #    script = helper.script
    #    print Time.new().to_s + "秒\n"
    #    #assert_equal(params['task.id'], 'bmcw');
    #    tables = helper.tables
    #    tables[0].Merge(3, 3, 5, 5)
    #    tables[0].InsertRow(5)
    #    tables[0].InsertCol(5)
    #    tables[0].SetCellValue(2, 1, "lmx")
    #    cell = tables[0].GetCell(2,1)
    #    
    #    assert_equal(tables[0].instance_eval("(a1 + ' wuxiangping')"), "lmx wuxiangping")
    #    tables[0].A1()
    #    tables[0].AA1()
    #    print "\nproperty" + tables[0].GetCellProperty(2, 1, StyleManager::PROP_filltype).to_s      
    #    tables[0].GetCellByFieldName('A1')
    #    #assert_equal(tables.length, 7)
    #    file = File.new('d:\param\a_ruby.xml', "wb")
    #    helper = XMLHelper.new
    #    file.write helper.REXML_WriteToXML(tables, dictFactory, script, params)
    #    file.close
    #end
    
    #def test_report_datasource
    #    ds = ReportDataSource.new()
    #    ds.Query("select * from keshi")
    #    print "\nrecord count: " + ds.GetRecordCount().to_s
    #    while ds.Next
    #        print ds.jm + "\n"
    #        
    #    end
    #end
    
    def test_report_engine
        print "begin report: #{Time.new} \n" 
        helper = XMLHelper.new
        
        helper.MS_ReadFromXMLFile('d:\param\hz.template')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        engine = ReportEngine.new()
#        tables[0] = engine.fill(tables[0], "select m.*, a.assetname, j.name jfkmname, k.name syks, c.name gbname, s.name ghsname
#
#
#
#from asset_main m, asset a
#
#
#
#left join dic_jfkm j on m.jfkm = j.code
#
#
#
#left join dic_country c on m.gb = c.code
#
#
#
#left join supplier s on m.ghs=s.id
#
#
#
#left join keshi k on k.id = m.sydw
#
#
#
#where m.assetid = a.id")
        #tables[0] = engine.fill(tables[0], "select * from keshi ")
#        tables[0] = engine.fill(tables[0], "select c.id, c.code, c.kth, c.lrr, c.sfzb, c.qsrq, s.name, a.assetname,  d.*, j.name jfkmname
#from contract c, contract_details d, asset a
#left join supplier s on c.supplierid = s.id 
#left join dic_jfkm j on d.jfkm = j.code
#where d.contactid=c.id and d.assetid = a.id ")
ActiveRecord::Base::establish_connection(
                :adapter => "mysql",
                :host => "localhost",
                :database => "fuwai",
                :port => "6807",
                :username => "root",
                :encoding => "gbk",
                :password => "")
        
        tables[0] = engine.fill(tables[0],
                                "select k.*, sum(m.dj) dj, a.cw_catalog, count(k.id) count from  
                                            asset_main m, keshi k, asset a where m.sydw=k.id and m.assetid = a.id and k.id < 20
                                            group by k.id, a.cw_catalog ",
                                script)
        file = File.new('d:\param\hz_ruby_script.html', "wb")
        helper = XMLHelper.new
        #file.write helper.REXML_WriteToXML(tables, dictFactory, script, params)
        file.write helper.TableToEditHTML(tables[0], dictFactory, {:onlyTableTag => false, :title => "hello", :page => 2, :readonly=>true, :linesperpage => 20, :showallpage => true})
        file.close
        
        print "end report: #{Time.new} \n" 
    end
    
    def test_table2EditHTML
        helper = XMLHelper.new
        helper.MS_ReadFromXMLFile('d:\param\cw.xml')
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        dictionFactory = helper.dictionFactory
        
        table = tables[0]
        Integer(0).upto(table.GetRowCount()-1) do |row|
        	#print "row #{row}\n"
        	if table.IsEmptyRow(row)
        		print "empty row #{row}\n"
        	else
        		print "logic row is " + table.PhyRowToLogicRow(row+1).to_s + "\n"
        	end
        	
        end
        #file = File.new('d:\param\rk.html', "wb")
        #file<< helper.TableToEditHTML(tables[0], dictionFactory, script, 'hello', "utf8")
        #file.close
    
    end
    
    def test_table2EditHTML
        helper = XMLHelper.new
        helper.MS_ReadFromXMLFile('d:\param\kb.xml')
        params = helper.parameters
        script = helper.script
        tables = helper.tables
        dictionFactory = helper.dictionFactory
        
        table = tables[1]
        
        file = File.new('d:\param\kb1.html', "wb")
        file<< helper.TableToEditHTML(table, dictionFactory, {:script => script, :readonly=>true, :title => 'haha', :only_table_tag=>false,:encoding=>"utf-8"})
        file.close
    
    end
    
    def ttest_unit_report_engine
        print "begin report: #{Time.new} \n" 
        helper = XMLHelper.new
        
        helper.MS_ReadFromXMLFile('d:\q.xml')
        dictFactory = helper.dictionFactory
        params = helper.parameters
        script = helper.script
        tables = helper.tables

        engine = ReportEngine.new()
        ActiveRecord::Base::establish_connection(
                :adapter => "mysql",
                :host => "localhost",
                :database => "apollo_ruby",
                :port => "3306",
                :username => "root",
                :encoding => "gbk",
                :password => "")
        
        tables[0] = engine.fill(tables[0], "select fm.unitid,fm.unitid as fm_unitid,fm.qymc as fm_qymc,fm.qydm as fm_qydm,fm.sjdm as fm_sjdm,fm.jtdm as fm_jtdm,fm.czdm as fm_czdm,fm.dbr as fm_dbr,fm.xzlsgx as fm_xzlsgx,fm.qylx as fm_qylx,fm.zbgc as fm_zbgc,fm.hylsgx as fm_hylsgx,fm.qygm as fm_qygm,fm.dz as fm_dz,fm.yzbm as fm_yzbm,fm.dh as fm_dh,fm.kysj as fm_kysj,fm.xbyy as fm_xbyy,fm.bblx as fm_bblx,fm.dym as fm_dym,fm.p_parent as fm_p_parent,fm.display as fm_display,zbb.unitid as zbb_unitid,zbb.tasktimeid as zbb_tasktimeid,zbb.a1 as zbb_a1,zbb.b1 as zbb_b1,zbb.c1 as zbb_c1,zbb.a2 as zbb_a2,zbb.b2 as zbb_b2,zbb.c2 as zbb_c2,zbb.a3 as zbb_a3,zbb.b3 as zbb_b3,zbb.c3 as zbb_c3,zbb.a4 as zbb_a4,zbb.b4 as zbb_b4,zbb.c4 as zbb_c4,zbb.a5 as zbb_a5,zbb.b5 as zbb_b5,zbb.c5 as zbb_c5,zbb.a6 as zbb_a6,zbb.b6 as zbb_b6,zbb.c6 as zbb_c6,zbb.a7 as zbb_a7,zbb.b7 as zbb_b7,zbb.c7 as zbb_c7,zbb.a8 as zbb_a8,zbb.b8 as zbb_b8,zbb.c8 as zbb_c8,zbb.a9 as zbb_a9,zbb.b9 as zbb_b9,zbb.c9 as zbb_c9,zbb.a10 as zbb_a10,zbb.b10 as zbb_b10,zbb.c10 as zbb_c10,zbb.a11 as zbb_a11,zbb.b11 as zbb_b11,zbb.c11 as zbb_c11,zbb.a12 as zbb_a12,zbb.b12 as zbb_b12,zbb.c12 as zbb_c12,zbb.a13 as zbb_a13,zbb.b13 as zbb_b13,zbb.c13 as zbb_c13,zbb.a14 as zbb_a14,zbb.b14 as zbb_b14,zbb.c14 as zbb_c14,zbb.a15 as zbb_a15,zbb.b15 as zbb_b15,zbb.c15 as zbb_c15,zbb.a16 as zbb_a16,zbb.b16 as zbb_b16,zbb.c16 as zbb_c16,zbb.a17 as zbb_a17,zbb.b17 as zbb_b17,zbb.c17 as zbb_c17,zbb.a18 as zbb_a18,zbb.b18 as zbb_b18,zbb.c18 as zbb_c18,zbb.a19 as zbb_a19,zbb.b19 as zbb_b19,zbb.c19 as zbb_c19,zbb.a20 as zbb_a20,zbb.b20 as zbb_b20,zbb.c20 as zbb_c20,zbb.a21 as zbb_a21,zbb.b21 as zbb_b21,zbb.c21 as zbb_c21,zbb.a22 as zbb_a22,zbb.b22 as zbb_b22,zbb.c22 as zbb_c22,zbb.a23 as zbb_a23,zbb.b23 as zbb_b23,zbb.c23 as zbb_c23,zbb.a24 as zbb_a24,zbb.b24 as zbb_b24,zbb.c24 as zbb_c24,zbb.a25 as zbb_a25,zbb.b25 as zbb_b25,zbb.c25 as zbb_c25,zbb.a26 as zbb_a26,zbb.b26 as zbb_b26,zbb.c26 as zbb_c26,zbb.a27 as zbb_a27,zbb.b27 as zbb_b27,zbb.c27 as zbb_c27,zbb.a28 as zbb_a28,zbb.b28 as zbb_b28,zbb.c28 as zbb_c28,zbb.a29 as zbb_a29,zbb.b29 as zbb_b29,zbb.c29 as zbb_c29,zbb.a30 as zbb_a30,zbb.b30 as zbb_b30,zbb.c30 as zbb_c30,zbb.a31 as zbb_a31,zbb.b31 as zbb_b31,zbb.c31 as zbb_c31,zbb.a32 as zbb_a32,zbb.b32 as zbb_b32,zbb.c32 as zbb_c32,zbb.a33 as zbb_a33,zbb.b33 as zbb_b33,zbb.c33 as zbb_c33,zbb.a34 as zbb_a34,zbb.b34 as zbb_b34,zbb.c34 as zbb_c34,zbb.a35 as zbb_a35,zbb.b35 as zbb_b35,zbb.c35 as zbb_c35,zbb.a36 as zbb_a36,zbb.b36 as zbb_b36,zbb.c36 as zbb_c36,zbb.a37 as zbb_a37,zbb.b37 as zbb_b37,zbb.c37 as zbb_c37,zbb.a38 as zbb_a38,zbb.b38 as zbb_b38,zbb.c38 as zbb_c38,zbb.a39 as zbb_a39,zbb.b39 as zbb_b39,zbb.c39 as zbb_c39,zbb.a40 as zbb_a40,zbb.b40 as zbb_b40,zbb.c40 as zbb_c40,zbb.a41 as zbb_a41,zbb.b41 as zbb_b41,zbb.c41 as zbb_c41,flzbb.unitid as flzbb_unitid,flzbb.tasktimeid as flzbb_tasktimeid,flzbb.a1 as flzbb_a1,flzbb.b1 as flzbb_b1,flzbb.c1 as flzbb_c1,flzbb.a2 as flzbb_a2,flzbb.b2 as flzbb_b2,flzbb.c2 as flzbb_c2,flzbb.a3 as flzbb_a3,flzbb.b3 as flzbb_b3,flzbb.c3 as flzbb_c3,flzbb.a4 as flzbb_a4,flzbb.b4 as flzbb_b4,flzbb.c4 as flzbb_c4,flzbb.a5 as flzbb_a5,flzbb.b5 as flzbb_b5,flzbb.c5 as flzbb_c5,flzbb.a6 as flzbb_a6,flzbb.b6 as flzbb_b6,flzbb.c6 as flzbb_c6,flzbb.a7 as flzbb_a7,flzbb.b7 as flzbb_b7,flzbb.c7 as flzbb_c7,flzbb.a8 as flzbb_a8,flzbb.b8 as flzbb_b8,flzbb.c8 as flzbb_c8,flzbb.a9 as flzbb_a9,flzbb.b9 as flzbb_b9,flzbb.c9 as flzbb_c9,flzbb.a10 as flzbb_a10,flzbb.b10 as flzbb_b10,flzbb.c10 as flzbb_c10,flzbb.a11 as flzbb_a11,flzbb.b11 as flzbb_b11,flzbb.c11 as flzbb_c11,flzbb.a12 as flzbb_a12,flzbb.b12 as flzbb_b12,flzbb.c12 as flzbb_c12,flzbb.a13 as flzbb_a13,flzbb.b13 as flzbb_b13,flzbb.c13 as flzbb_c13,flzbb.a14 as flzbb_a14,flzbb.b14 as flzbb_b14,flzbb.c14 as flzbb_c14,flzbb.a15 as flzbb_a15,flzbb.b15 as flzbb_b15,flzbb.c15 as flzbb_c15,flzbb.a16 as flzbb_a16,flzbb.b16 as flzbb_b16,flzbb.c16 as flzbb_c16,flzbb.a17 as flzbb_a17,flzbb.b17 as flzbb_b17,flzbb.c17 as flzbb_c17,flzbb.a18 as flzbb_a18,flzbb.b18 as flzbb_b18,flzbb.c18 as flzbb_c18,flzbb.a19 as flzbb_a19,flzbb.b19 as flzbb_b19,flzbb.c19 as flzbb_c19,flzbb.a20 as flzbb_a20,flzbb.b20 as flzbb_b20,flzbb.c20 as flzbb_c20,flzbb.a21 as flzbb_a21,flzbb.b21 as flzbb_b21,flzbb.c21 as flzbb_c21,flzbb.a22 as flzbb_a22,flzbb.b22 as flzbb_b22,flzbb.c22 as flzbb_c22,flzbb.a23 as flzbb_a23,flzbb.b23 as flzbb_b23,flzbb.c23 as flzbb_c23,flzbb.a24 as flzbb_a24,flzbb.b24 as flzbb_b24,flzbb.c24 as flzbb_c24,flzbb.a25 as flzbb_a25,flzbb.b25 as flzbb_b25,flzbb.c25 as flzbb_c25,flzbb.a26 as flzbb_a26,flzbb.b26 as flzbb_b26,flzbb.c26 as flzbb_c26,flzbb.a27 as flzbb_a27,flzbb.b27 as flzbb_b27,flzbb.c27 as flzbb_c27,flzbb.a28 as flzbb_a28,flzbb.b28 as flzbb_b28,flzbb.c28 as flzbb_c28,flzbb.a29 as flzbb_a29,flzbb.b29 as flzbb_b29,flzbb.c29 as flzbb_c29,flzbb.a30 as flzbb_a30,flzbb.b30 as flzbb_b30,flzbb.c30 as flzbb_c30,flzbb.a31 as flzbb_a31,flzbb.b31 as flzbb_b31,flzbb.c31 as flzbb_c31,flzbb.a32 as flzbb_a32,flzbb.b32 as flzbb_b32,flzbb.c32 as flzbb_c32,flzbb.a33 as flzbb_a33,flzbb.b33 as flzbb_b33,flzbb.c33 as flzbb_c33,flzbb.a34 as flzbb_a34,flzbb.b34 as flzbb_b34,flzbb.c34 as flzbb_c34,flzbb.a35 as flzbb_a35,flzbb.b35 as flzbb_b35,flzbb.c35 as flzbb_c35,flzbb.a36 as flzbb_a36,flzbb.b36 as flzbb_b36,flzbb.c36 as flzbb_c36,flzbb.a37 as flzbb_a37,flzbb.b37 as flzbb_b37,flzbb.c37 as flzbb_c37,flzbb.a38 as flzbb_a38,flzbb.b38 as flzbb_b38,flzbb.c38 as flzbb_c38 from ytapl_KJYB_FM fm,ytapl_KJYB_ZBB zbb,ytapl_KJYB_FLZBB flzbb where 1=1 and zbb.unitid = fm.unitid and flzbb.unitid = fm.unitid and flzbb.tasktimeid = zbb.tasktimeid and zbb.tasktimeid in (45,46) ")
        file = File.new('d:\q.html', "wb")
        helper = XMLHelper.new
        file.write helper.TableToEditHTML(tables[0], dictFactory, {:onlyTableTag => false, :title => "hello", :page => 2, :readonly=>true, :linesperpage => 20, :showallpage => true})
        file.close
        
        print "end report: #{Time.new} \n" 
    end
end

