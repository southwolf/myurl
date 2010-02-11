class TaskScriptEngine
  attr_reader :taskstrid, :unitid
  #初始化任务脚本引擎
  #taskstrid:任务id，如QYKB
  #script:   脚本，CTaskScript实例
  #unitid:   单位id，如1111111117
  #tasktime: 任务时间，Time类型
  #tables:   表数组，元素为CTable实例
  #records:  数据数组，ActiveRecord::Base实例
  #sum_mode: 汇总模式，在这种模式下，没有封面表
  def initialize(taskstrid, script, unitid, tasktime, tables, records, sum_mode=false)
    @taskstrid = taskstrid
    @script = script
    @unitid = unitid
    @tasktime = tasktime
    @tables = tables
    @records = records
    
    @table_script_engines = Array.new
    
    Integer(0).upto(@tables.size-1) do |i|
      @table_script_engines << TableScriptEngine.new(@tables[i], records[i], i==0 && !sum_mode, tasktime, self)
    end
  end

  #执行某张表的运算公式
  def ExecuteCalc(tablename)    
    YtLog.info "Execute calc script of " + tablename
    in_table = false
    for element in @table_script_engines
      if tablename.downcase == element.TableName().downcase
        YtLog.info "dispatch to #{element.TableName}\n"
        @current_table_script = element
        in_table = true
      end
    end
    
    @current_table_script = @current_table_script || @table_script_engines[0]
    lines = @script.getCalcScript(tablename)
    if lines
      #YtLog.info lines
      #YtLog.info predeal_calc(lines.downcase)
      @current_table_script.instance_eval(predeal_calc(lines.downcase))
    end
    
  end
  
  #执行某张表的审核公式, 如果tablename为空则执行表间审核公式
  def ExecuteAudit(tablename, clearerrors = true)
    in_table = false
    for element in @table_script_engines
      if tablename.downcase == element.TableName().downcase
        @current_table_script = element
        in_table = true
        braek
      end
    end
    
    @current_table_script = @current_table_script || @table_script_engines[0]
    
    if clearerrors
      @errors = Array.new
      @warns = Array.new
    end
    
    lines = @script.getAuditScript(tablename)
    if lines
      lines.each { |line|
#        YtLog.info(line)
        next if !line || line.strip().size <1
        @current_table_script.current_audit_text = extract_script(line) #设置审核公式的文本串，以便查看现场
        #YtLog.info(predeal_audit(line.downcase))
        @current_table_script.instance_eval(predeal_audit(line.downcase))
    }
    end
    
    for error in @current_table_script.errors
      @errors << error
    end
    
    for warn in @current_table_script.warns
      @warns << warn
    end
  end
  
  def month()
    @tasktime.month
  end
  
  #从audit(a>b,'a要大于b'， _a, _b)这样的公式中抽取出"a>b"这样的公式
  def extract_script(line)
    #line = line[0, line.index('//')]    
    
    text = line.gsub(/audit\s*\(/, "")
    text = text.gsub(/warn\s*\(/, "")
    line = text[0, text.index(',')]  if text.index(',')
    YtLog.info line
    line
  end
  
  #对计算公式进行预处理
  def predeal_calc(line)
    #将a=b+qybb.c翻译为self.a=self.b+self.qybb.c
    #line = line.gsub(/[a-zA-Z]\w*/, 'self.\0')
    #line = line.gsub(/(self.)(if|then|else|elsif|nil|when|def|false|true|while|do|end|return|break|next|for|self|class|ensure|until|yield)/, '\2')
    
    #将"[1] = [2]"翻译为self[1] = self[2]
    line = line.gsub(/^([\[.*\]])/, 'self\0')             
    line = line.gsub(/([\W^])(\[\d*\])/, '\1self\2')    
    
    #将a=b+c 翻译为self.a=b+c
    line = " " + line                             #字符串首加一个空格
    line.gsub!("\n", "\n ")                       #每个回车符后加一个空格
    line.gsub!(/[ ](\w+\s*[+|-]?=)/) {|i|	" self."+i.gsub!(/^[ ]+/, '') }   #空格加表达式换成self.表达式
    line.gsub!("@self.", "@")                     #遇见@self.的要取消self.
    
    YtLog.info(line)
    line
  end
  
  
  #对审核公式进行预处理，如把[1] = [2] 变成self[1] = self[2]
  def predeal_audit(line)    
    #将"[1] = [2]"翻译为self[1] = self[2]
    text = line.gsub(/^([\[.*\]])/, 'self\0')             #替换顶格的[1]
    text = text.gsub(/([\W^])(\[\d*\])/, '\1self\2')
    text = text.gsub(/(self.)(if|then|else|elsif|nil|when|def|false|true|while|do|end|return|break|next|for|self|class|ensure|until|yield)/, '\2')
    
    #将#1 翻译为 self[1]
    text = text.gsub(/(#)(\d+)/, 'self[\2]')
    
    return text
    
    text = text.gsub(/(.*)(>=|<=|==|>|<)(.*)(\/\/)(.*)/, 'audit(\1 \2 \3, "\5"')    #将"[1] > [2]//第一行大于第二行"翻译为audit([1]>[2], "第一行大于第二行")
    #查找并将[18]翻译为_18
	line.gsub(/\B(\[)(\d*)(\])/){|row|
		text += ",_" + row[1, row.size-2]
	}
	
	#查找并将qykb[18]翻译为qykb._18
	line.gsub(/(\w)+\[(\d*)\]/){|row|
		text += "," + row.gsub("[", "._").gsub("]", "")
	}
	
	#查找并将a翻译为_a
	
	#查找并将qykb.a1翻译为qykb._a1
	line.gsub(/\w+\.\w+/){|cell|
		text += "," + cell.gsub(".", "._")
	}
	
	#查找并将a1翻译为_a1
	line.gsub(/\w+[\.\[\]]*\w*/){|cell|
		next if cell.index(".")
		next if cell.index("[")
		next if cell.index("]")
		next if cell.gsub(/\d+/, "").size == 0
		text += ",_" + cell
	}
	
	text += ")"
    text
  end
  
  #执行所有表的运算公式
  def ExecuteAllCalc()
      for table in @tables
        begin
        	ExecuteCalc(table.GetTableID())
        rescue Exception=>err
        	p err
        end
      end
      ExecuteCalc("")
     
     for element in @table_script_engines
      if 1#element.changed?  
        if element.IsFaceTable()
          UnitFMTableData.set_table_name("ytapl_#{@taskstrid}_#{element.TableName()}".downcase)
          UnitFMTableData.reset_column_information
        else
          UnitTableData.set_table_name("ytapl_#{@taskstrid}_#{element.TableName()}".downcase)
          UnitTableData.reset_column_information
        end

        element.TableRecord().save 
      end
    end
  end
  
  #执行所有表的审核公式
  def ExecuteAllAudit()
    @errors = Array.new
    @warns = Array.new
      
    for table in @tables
        ExecuteAudit(table.GetTableID(), false)
    end
    ExecuteAudit("", false)
  end

  
  def GetErrors()
    @errors
  end
  
  def GetWarns()
    @warns
  end
  
  #返回公式引擎表对象
  def method_missing(method_id, *args) 
    name = method_id.id2name.to_s.downcase
    
    if name=='task'
      return self
    end
    
    for element in @table_script_engines
      if element.TableName().downcase() == name.downcase
        return element 
      end
    end
    
    return @current_table_script.instance_eval(name)
  end 

  #进行运算审核前的准备
  def Prepare
    for element in @table_script_engines
      element.SetOutTables(@table_script_engines)
      element.Prepare
    end
  end
end

#公式引擎表对象
class TableScriptEngine
  attr_accessor :current_audit_text
  #record类型是ActiveRecord，代表一个单位的一张表的数据
  #tasktime是Time类型,表示哪期的数据
  def initialize(table, record, isface, tasktime, task)
    @table = table
    @record = record
    @changed = false
    @isface = isface
    @audit_error = Array.new
    @audit_warn = Array.new
    @tasktime = tasktime
    @task = task
    
    #当前审核的公式
    @current_audit_text = ""
    
    #p @record
    
    for field in record.attribute_names() 
      #为每个字段定义一个函数，如a1=, b3=      
      
      instance_eval("def #{field.downcase()}=(other)
                      for field1 in @record.attribute_names()
                        if field1.downcase() == '#{field}'.downcase()
                          @record[\"\#{field1}\"] = other 
                          @changed = true
                          return
                        end
                      end        
                     end")
                     
      #同时需要定义_a1, _a2这样的函数，返回'zbb.a1', 'FM.b1'这样的字符串，用来进行审核时候的错误定位
      instance_eval("def _#{field.downcase()}()                      
                      return '#{@table.GetTableID()}.#{field}'      
                     end")
    end
    
    #定义行定位公式如_1, _2，返回一个数组,里面元素如_a1, _b1, _c1
    Integer(0).upto(@table.GetRowCount()-1) do |row|
        next if @table.IsEmptyRow(row)
        logicRow = @table.PhyRowToLogicRow(row+1)
        
        script = ""
        Integer(0).upto(@table.GetColumnCount()-1) do |col|
            next if @table.IsEmptyCol(col)
            logicCol = @table.PhyColToLogicCol(col+1)
            #script += "result << _#{(logicCol + 64).chr.downcase}#{logicRow}"
            script += "result << _#{table.GetCellLabel(row, col).downcase}"
            script += "\n"
        end
        instance_eval("def _#{logicRow}()
                          result = Array.new
                          #{script}
                          result
                       end")    
    end                   
      
    
    
    #为每列定义一个函数，如A=, B=, D=
    index = 1
    Integer(0).upto(@table.GetColumnCount-1) do |col|
      next if @table.IsEmptyCol(col)

      if not @table.IsFloatTable()
        #instance_eval("def #{(index+64).chr.downcase}= (other)
        instance_eval("def #{table.GetColLabel(col).downcase}= (other)
                        SetColValue(#{index}, other)      
                      end")
      
      #如果是浮动表，则列公式比较复杂                      
      else
        instance_eval("def #{table.GetColLabel(col).downcase}= (other)
                        SetFloatColValue(#{index}, other)
                      end")
      end
      
      index += 1
    end
    
    #为每列定义定位函数，如_a,_b,返回一个数组,里面元素如_a1, _a2, _a3
    Integer(0).upto(@table.GetColumnCount()-1) do |col|
      next if @table.IsEmptyCol(col)
      logicCol = @table.PhyColToLogicCol(col+1)
      
      script = ""
      Integer(0).upto(@table.GetRowCount()-1) do |row|
            next if @table.IsEmptyRow(row)
            logicRow = @table.PhyRowToLogicRow(row+1)
            #script += "result << _#{(logicCol + 64).chr.downcase}#{logicRow}"
            script += "result << _#{table.GetColLabel(col).downcase}#{logicRow}"
            script += "\n"
      end
 
      #instance_eval("def _#{(logicCol + 64).chr.downcase}()
      instance_eval("def _#{table.GetColLabel(col).downcase}()
                          result = Array.new
                          #{script}
                          result
                       end")    
    end
    
    #p @record
  end
  
  #设置外部表数组，元素类型是TableScriptEngine，这样可以在T1表中访问T2表
  def SetOutTables(others)
    @out_tables = others
  end
  
  #初始化,为每张表建立函数，如t2(), t3()
  def Prepare
    for element in @out_tables
      instance_eval("def #{element.TableName().downcase()}
                      for ele in @out_tables
                        return ele if ele.TableName().downcase() == '#{element.TableName().downcase()}'                        
                        nil
                      end
                    end")
    end
  end
  
  #获得审核错误
  def errors
    @audit_error
  end
  
  #获得警告型错误
  def warns
    @audit_warn
  end
  
  
  #浮动行条件汇总
  #templrow 浮动模板行，浮动区域
  #condition  条件表达式
  #sumcol 汇总列对象 ColumnScriptEngine
  def fltsumif(templrow, conditions, sumcol)
      YtLog.info 'into fltsumif ... '
      YtLog.info conditions
      
      fixcondition = false
      if conditions.kind_of?(String)
        fixcondition = ( conditions == 'true' )
      end
      
      result = Integer(0)
      
      begin
        require "Util"
        records = Util.GetFloatData(@task.taskstrid, @table.GetTableID(), templrow, @record.unitid, @record.tasktimeid, 1, 50000)
        
        return result if not @table.IsFloatTable()
        return result if templrow>@table.GetRowCount() or sumcol.Column()>@table.GetColumnCount()
        
        index = Integer(0)
        for record in records
          field = "#{@table.GetColLabel(sumcol.Column()-1).downcase}#{templrow}"
          for field1 in record.attribute_names()
            if field1.downcase() == field
              result += Float(record[field1]) if conditions[index] or fixcondition
              break
            end
          end
          
          index += 1
        end
      rescue
        YtLog.info "error occur in function: fltsumif()..."
      end
      
      YtLog.info result
      
      return result
  end
  
  
  #浮动行条件汇总
  #templrow 浮动模板行，浮动区域
  #sumcol 汇总列对象 ColumnScriptEngine
  def fltsum(templrow, sumcol)
      fltsumif(templrow, "true", sumcol)
  end
  
  
  #审核，错误信息存放在@audit_error数组中，每个元素又是一个数组，元素0存放错误信息，元素1又是一个数组，存放所有定位单元格，存放所有定位单元格，元素2存放公式
  def audit(expr, msg, *cells)
    if expr.kind_of?(Array)
      index = 0
      for element in expr
        if element
          index += 1
          next
        end
        error = Array.new
        error[0] = msg
        
        errorCells = Array.new
        for cell in cells
          errorCells << cell[index]
        end
        error[1] = errorCells
        error[2] = @current_audit_text
        @audit_error << error
        
        YtLog.info "audit array error : #{msg}, error cells are "
        YtLog.info error[1]
        
        index += 1
      end
      return
    end
  
    if !expr
        error = Array.new
        error[0] = msg
        error[1] = cells
        error[2] = @current_audit_text
        @audit_error << error
        YtLog.info "audit cell error : #{msg}, error cells are #{cells}"
    end
  end
  
  #警告型审核，错误信息存放在@audit_error数组中，每个元素又是一个数组，元素0存放错误信息，元素1又是一个数组，存放所有定位单元格，元素2存放公式
  def warn(expr, msg, *cells)
    if expr.kind_of?(Array)
      index = 0
      for element in expr
        if element
          index += 1
          next
        end
        error = Array.new
        error[0] = msg
        
        errorCells = Array.new
        for cell in cells
          errorCells << cell[index]
        end
        error[1] = errorCells
        error[2] = @current_audit_text
        @audit_warn << error
        
        YtLog.info "audit warn : #{msg}, error cells are "
        
        index += 1
      end
      return
    end
  
    if !expr
        error = Array.new
        error[0] = msg
        error[1] = cells
        error[2] = @current_audit_text
        @audit_warn << error
        YtLog.info "audit warn : #{msg}, error cells are "
        YtLog.info cells
    end
  end
  
  def month(step)
    YtLog.info "month called step is #{step}"
    newtasktime = @tasktime.months_ago(-step)
    UnitTableData.set_table_name("ytapl_#{@task.taskstrid}_#{@table.GetTableID()}".downcase)
    UnitTableData.reset_column_information() 
    task = Task.find(:all, :conditions=>"strid = '#{@task.taskstrid}'")[0]    
    times = Yttasktime.find(:all, :conditions=>"taskid = #{task.id} and begintime = '#{newtasktime.strftime('%Y-%m-%d')}'")    
    record = UnitTableData.find [@record.unitid, times[0].id] rescue nil if times.size > 0     
    if !record
      record = UnitTableData.new
      record.unitid = @record.unitid
    end
    record.get_typed_value
    return TableScriptEngine.new(@table, record, false, newtasktime, @task)
  end
  
  
  
  def unit(unitid)
    YtLog.info "unit called unitid is #{unitid}"
    UnitTableData.set_table_name("ytapl_#{@task.taskstrid}_#{@table.GetTableID()}".downcase)
    UnitTableData.reset_column_information() 
    task = Task.find(:all, :conditions=>"strid = '#{@task.taskstrid}'")[0]   
    times = Yttasktime.find(:all, :conditions=>"taskid = #{task.id} and begintime = '#{@tasktime.strftime('%Y-%m-%d')}'")    
    
    begin
      record = UnitTableData.find [unitid, times[0].id]
    rescue
      record = nil
    end
    
    if !record
      YtLog.info "不能找到单位(#{unitid})的数据"
      return nil
      #record = UnitTableData.new
      #record.unitid = unitid
    end
    record.get_typed_value
    return TableScriptEngine.new(@table, record, false, @tasktime, @task)
  end
  
  
  #获取浮动行公式对象
  def getfloatrow(templrow)
    YtLog.info "getFloatRow(#{templrow})"
    if not @table.IsFloatTable()
      return nil
    end
    return FloatRowScriptEngine.new(@task, @table, templrow, @record)
  end
  
  
  
  #获得审核错误,错误信息存放在@audit_error数组中，每个元素又是一个数组，元素0存放错误信息，元素1又是一个数组，存放所有定位单元格
  def GetAuditError()
    @audit_error
  end
  
  #col是逻辑列号, other是另一个ColumnScriptEngine
  def SetColValue(col, other)
    phyCol = @table.LogicColToPhyCol(col)
  
    index = 0
    Integer(0).upto(@table.GetRowCount()-1) do |row|
      next if @table.IsEmptyRow(row)
      field = @table.GetCellDBFieldName(row, phyCol)
      next if field == ""
      #print "field name is #{field} values is #{other.Values[index]}\n"
      
      @record[field] = other.Values[index]
      
      index += 1
      @changed = true
    end
    
  end
  
  
  def SetFloatColValue(col, other)
    floatColumn = FloatColumnScriptEngine.new(@task, @table, col, @record)
    floatColumn.Assign( other )
    floatColumn.Save
    @changed = true
  end
  
  #给行赋值的函数，args[0]为行号，args[1]为另一个RowScriptEngine对象
  def []=(*args)
    row = args[0]
    row_engine = args[1]
    
    phyRow = @table.LogicRowToPhyRow(row)
    
    i = 0
    Integer(0).upto(@table.GetColumnCount()-1) do |col|
      next if @table.IsEmptyCol(col)
      
      field = @table.GetCellDBFieldName(phyRow, col)
      @record[field] = row_engine.Values[i]
#      print "#{field} 's value is #{row_engine.Values[i]}"
      @changed = true
      i += 1
    end
    #row_script = RowScriptEngine.new(@table, row, @record)
  end
  
  def TableName()
    @table.GetTableID()
  end
  
  def TableRecord()
    @record
  end
  
  #是否封面表
  def IsFaceTable()
    @isface
  end
  
  #是否已改变，如果没变则不操作数据库，节省数据库操作
  def changed?
    @changed
  end
  
  #在这里返回单元格的内容，如果找不到则返回0
  def method_missing(method_id, *args) 
    name = method_id.id2name.to_s.downcase
    
    if name == 'task'
      return @task
    end
    
    #判断是否是单元格操作, 如a1, c2. 遇空值返回0
    for field in @record.attribute_names()
      if field.downcase == name
        if @record["#{field}"] == nil
          return 0
        else
          return @record["#{field}"]
        end        
      end 
    end
    
    #判断是否是行操作,如[1], [3]
    if name == "[]"
      row = RowScriptEngine.new(@table, args[0], @record)
      #YtLog.info "scriptrow created" + args[0].to_s
      return row
    end
    
    #判断是否是列操作, 如a, b
    Integer(0).upto(@table.GetColumnCount-1) do |col|
      next if @table.IsEmptyCol(col)
      logicCol = @table.PhyColToLogicCol(col+1)
      if (logicCol+64).chr.downcase == name.downcase()
        #YtLog.info "new column script created\nname is #{name}\nlogicCol is #{logicCol}"
        #YtLog.info @table.GetTableID()
        if not @table.IsFloatTable()
          return ColumnScriptEngine.new(@table, logicCol, @record)
        else
          return FloatColumnScriptEngine.new(@task, @table, logicCol, @record)
        end
      end
    end
    
    return 0
  end
end

#公式引擎行对象，代表一张表的某一行或这一行的一个部分，如T1[1], [1], [9][A, D], [5][a..b, e..f, g, h].. 
class RowScriptEngine
  #row为逻辑行
  def initialize(table, row, record)
    @row = row
    @table = table
    @record = record
    @values = Array.new
    @effect_values = Array.new
    @valid = Array.new  #离散公式使用，表示有效的点
    
    #逻辑行转成物理行
    count = 0
    Integer(0).upto(table.GetRowCount()-1) do |row|
      count += 1 if !table.IsEmptyRow(row)
      if count == @row 
        count = row
        break
      end
    end
    
    
    Integer(0).upto(table.GetColumnCount()-1) do |col|
      next if table.IsEmptyCol(col)
      @values << record["#{table.GetCellDBFieldName(count, col)}"]
      @valid << true
    end

  end
  
  def Values
    @values
  end
  
  def /(other)
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i] || !@valid[i]
      if other.Values[i].to_f != 0
        @values[i] = @values[i].to_f / other.Values[i].to_f 
      else
        @values[i] = 0
      end
    end
    
    return self
  end
  
  def *(other)
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i] || !@valid[i]
      @values[i] = @values[i].to_f * other.Values[i].to_f
    end
    
    return self
  end
  
  def +(other)
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i] || !@valid[i]
      @values[i] = @values[i] + other.Values[i]
    end
    
    return self
  end
  
  def -(other)
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i] || !@valid[i]
      @values[i] -= other.Values[i]
    end
    
    return self
  end
  
  def abs
    Integer(0).upto(@values.length-1) do |i|
      @values[i] = @values[i].abs rescue nil
    end
    
    return self
  end
  
  #行对象比较，如[1] > [2]，返回结果是一个数组，里面存放true或false
  def >(other)
    result = Array.new
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      if (@values[i]||0) > other.Values[i] || !@valid[i]
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #行对象比较，如[1] >= [2]，返回结果是一个数组，里面存放true或false
  def >=(other)
    result = Array.new
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      if (@values[i]||0) >= other.Values[i] || ((@values[i]||0)-other.Values[i]).abs<0.00001|| !@valid[i]
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #行对象比较，如[1] < [2]，返回结果是一个数组，里面存放true或false
  def <(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      if (@values[i]||0) < other.Values[i] || !@valid[i]
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #行对象比较，如[1] <= [2]，返回结果是一个数组，里面存放true或false
  def <=(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      if (@values[i]||0) <= other.Values[i] || ((@values[i]||0)-other.Values[i]).abs<0.00001 || !@valid[i]
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #行对象比较，如[1] == [2]，返回结果是一个数组，里面存放true或false
  def ==(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      if ((@values[i]||0) - other.Values[i]).abs<0.00001 || !@valid[i]
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  def [](*args)
    Integer(0).upto(@valid.size-1) do |i|
      @valid[i] = false
    end
    for arg in args
      break if arg.kind_of?(RowScriptEngine)
      if arg.kind_of?(Fixnum)
        @valid[arg-1] = true
      end
      
      if arg.kind_of?(Range)
        for index in arg
          @valid[index-1] = true
        end
      end
    end
    self
  end

  #处理类似[1][1..3, 4, 5] = [2] + [3]
  def []=(*args)
    i=0
    for arg in args
      if arg.kind_of?(RowScriptEngine)
        other = arg
        break 
      end
      i += 1
    end
    
    phyRow = @table.LogicRowToPhyRow(@row)
    
    for arg in args
      break if arg.kind_of?(RowScriptEngine)
      if arg.kind_of?(Fixnum)
        phyCol = @table.LogicColToPhyCol(arg)
        next if phyCol > @table.GetColumnCount()   #检查是否越界
        field = @table.GetCellDBFieldName(phyRow, phyCol)
        @record[field] = other.Values[arg-1]
      end
      
      if arg.kind_of?(Range)
        for index in arg
          phyCol = @table.LogicColToPhyCol(index)
          next if phyCol > @table.GetColumnCount()   #检查是否越界
          field = @table.GetCellDBFieldName(phyRow, phyCol)
          @record[field] = other.Values[index-1]
        end
      end
    end
  end
end












#公式引擎行对象，代表一张表的某一行或这一行的一个部分，如T1[1], [1], [9][A, D], [5][a..b, e..f, g, h].. 
class FloatRowScriptEngine

  attr_accessor :row

  def initialize(task, table, templrow, record)
    #YtLog.info "FloatRowScriptEngine initialize..."
    @row = 0
    @task = task
    @table = table
    @record = record
    @values = Array.new
    @effect_values = Array.new
    @valid = Array.new  #离散公式使用，表示有效的点
    @templrow = templrow
    
    #逻辑行转成物理行
    count = 0
    
    require "Util"
    @records = Util.GetFloatData(@task.taskstrid, @table.GetTableID(), @templrow, @record.unitid, @record.tasktimeid, 1, 50000)

    
    Integer(0).upto(@table.GetColumnCount()-1) do |col|
      next if @table.IsEmptyCol(col)            
      instance_eval("def #{@table.GetColLabel(col).downcase}#{@templrow}= (other)
                        SetValue(#{col}, other)
                      end")
                      
      #同时需要定义_a1, _a2这样的函数，返回'zbb.a1', 'FM.b1'这样的字符串，用来进行审核时候的错误定位
      instance_eval("def _#{@table.GetColLabel(col).downcase}#{@templrow}()()                      
                      return '#{@table.GetTableID()}._#{@table.GetColLabel(col).downcase}#{@templrow}'      
                     end")
                     
    end
    
  end
  
  def rowcount
    #YtLog.info "FloatRowScriptEngine RowCount #{@records.size}"
    @records.size
  end
  
  def SetValue(col, other)
    field = "#{@table.GetColLabel(col)}#{@templrow}"
    @records[@row]["#{field}"] = other
    #YtLog.info "FloatRowScriptEngine SetValue( #{@row}, #{col}, #{other} )"
    @records[@row].update
  end
  
  
  #在这里返回单元格的内容，如果找不到则返回0
  def method_missing(method_id, *args) 
    name = method_id.id2name.to_s.downcase

    #判断是否是单元格操作, 如a1, c2. 遇空值返回0
    for field in @record.attribute_names()
      if field.downcase == name
        if @records[@row]["#{field}"] == nil
          return 0
        else
          return @records[@row]["#{field}"]
        end        
      end 
    end
  end 
  
end












#公式引擎列对象，代表一张表的某一列或这一列的一个部分，如T1.A, B, D[1, 5], E[1..3, 5..8, 9]..
class ColumnScriptEngine
  #col为逻辑列
  def initialize(table, col, record)
    @col = col
    @table = table
    @record = record
    @values = Array.new
    @effect_values = Array.new
    
    #逻辑行转成物理行
    count = @table.LogicColToPhyCol(col)
    
    
    Integer(0).upto(table.GetRowCount()-1) do |row|
      next if table.IsEmptyRow(row)
      next if table.GetCellDBFieldName(row, count) == ""
      @values << record["#{table.GetCellDBFieldName(row, count)}"]
    end
  end
  
  def Values()
    @values
  end
  
  def Record()
    @record
  end
  
  def Column()
    @col
  end
  
  def /(other)
    if other.kind_of?(Numeric)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = (@values[i].to_f / other.to_f) if other.to_f != 0
      end
    elsif other.kind_of?(ColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        if other.Values[i].to_f != 0
          @values[i] = (@values[i].to_f / other.Values[i].to_f) 
        else
          @values[i] = 0
        end
      end
    end
    
    return self
  end
  
  def *(other)
    if other.kind_of?(Numeric)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = (@values[i] * other) if @values[i].kind_of?(Numeric)
        @values[i] = (@values[i].to_f * other) if @values[i].kind_of?(String)
        
      end
    elsif other.kind_of?(ColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        next if !other.Values[i]
        @values[i] = (@values[i].to_f * other.Values[i].to_f)
      end
    end
    
    return self
  end
  
  def +(other)
    if other.kind_of?(Numeric)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = @values[i] + other if @values[i].kind_of?(Numeric)
        @values[i] = @values[i].to_f + other if @values[i].kind_of?(String)
      end
    elsif other.kind_of?(ColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        next if !other.Values[i]
        @values[i] = @values[i].to_f + other.Values[i].to_f
      end
    end
    
    return self
  end
  


  def -(other)
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      @values[i] -= other.Values[i]
    end
    
    return self
  end
  
  def abs()
    Integer(0).upto(@values.length-1) do |i|
      @values[i] = @values[i].abs rescue nil
    end
    
    return self
  end
  
  #列对象比较，如[1] > [2]，返回结果是一个数组，里面存放true或false
  def >(other)
    result = Array.new
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      next if @effect_cells.size > 0 && @effect_cells.include?(i+1)
      if ((@values[i]||0) > other.Values[i])
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #列对象比较，如[1] >= [2]，返回结果是一个数组，里面存放true或false
  def >=(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      next if @effect_cells.size > 0 && @effect_cells.include?(i+1)
      if ((@values[i]||0) >= other.Values[i]) || ((@values[i]||0)-other.Values[i]).abs<0.00001
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #列对象比较，如[1] < [2]，返回结果是一个数组，里面存放true或false
  def <(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      next if @effect_cells.size > 0 && @effect_cells.include?(i+1)
      if ((@values[i]||0) < other.Values[i])
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #列对象比较，如[1] <= [2]，返回结果是一个数组，里面存放true或false
  def <=(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      next if @effect_cells.size > 0 && @effect_cells.include?(i+1)
      if ((@values[i]||0) <= other.Values[i]) || ((@values[i]||0)-other.Values[i]).abs<0.00001
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  #列对象比较，如[1] == [2]，返回结果是一个数组，里面存放true或false
  def ==(other)
    result = Array.new
    
    Integer(0).upto(@values.length-1) do |i|
      next if !other.Values[i]
      next if @effect_cells.size > 0 && @effect_cells.include?(i+1)
      if ((@values[i]||0) - other.Values[i]).abs < 0.00001
        result << true
      else
        result << false
      end
    end
    
    result
  end
  
  def [](*args)
    for arg in args
      if arg.kind_of?(Fixnum)
        phyRow = @table.LogicRowToPhyRow(arg)
        next if phyRow > @table.GetRowCount()   #检查是否越界
        @effect_values << arg
      end
      
      if arg.kind_of?(Range)
        for index in arg
          next if index > @values.length   #检查是否越界
          @effect_values << arg
        end
      end
    end  
    self
  end
  
  #处理类似A[1..3, 4, 5] = B + C的运算
  def []=(*args)
    i=0
    for arg in args
      if arg.kind_of?(ColumnScriptEngine)
        other = arg
        break 
      end
      i += 1
    end
    
    phyCol = @table.LogicColToPhyCol(@col)
    
    for arg in args
      break if arg.kind_of?(ColumnScriptEngine)
      if arg.kind_of?(Fixnum)
        phyRow = @table.LogicRowToPhyRow(arg)
        next if phyRow > @table.GetRowCount()   #检查是否越界
        field = @table.GetCellDBFieldName(phyRow, phyCol)
        @record[field] = other.Values[arg-1]
      end
      
      if arg.kind_of?(Range)
        for index in arg
          next if index > @values.length   #检查是否越界
          phyRow = @table.LogicRowToPhyRow(index)
          field = @table.GetCellDBFieldName(phyRow, phyCol)
          @record[field] = other.Values[index-1]
        end
      end
    end
  end
end






















#公式引擎列对象，代表一张表的某一列或这一列的一个部分，如T1.A, B, D[1, 5], E[1..3, 5..8, 9]..
class FloatColumnScriptEngine
  #col为逻辑列
  def initialize(task, table, col, record)
    @col = col
    @task = task
    @table = table
    @record = record
    @values = Array.new
    @effect_values = Array.new
    @templrow = 1
    
    require "Util"
    @records = Util.GetFloatData(@task.taskstrid, @table.GetTableID(), @templrow, @record.unitid, @record.tasktimeid, 1, 50000)
    
    #逻辑行转成物理行
    count = @table.LogicColToPhyCol(col)
    
    for rec in @records
      field = "#{@table.GetColLabel(Column()-1).downcase}#{@templrow}"
      for field1 in rec.attribute_names()
        if field1.downcase() == field
          @values << rec.column_for_attribute(field1).type_cast(rec[field1]) 
          break
        end
      end
    end
  end
  
  def Save()
    index = Integer(0)
    for record in @records
      field = "#{@table.GetColLabel(Column()-1).downcase}#{@templrow}"
      #YtLog.info field
      for field1 in record.attribute_names()
        if field1.downcase() == field
          record[field1] = @values[index]
          #YtLog.info @values[index]
          break
        end
      end
      
      record.update()
      
      index += 1
    end
  end
  
  def Values()
    @values
  end
  
  def Record()
    @record
  end
  
  def Records()
    @records
  end
  
  def Column()
    @col
  end
  
  def /(other)
    if other.kind_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        next if other.Values[i] == 0
        @values[i] = @values[i].to_f / other.Values[i].to_f
      end
    else
      Integer(0).upto(@values.length-1) do |i|
        next if other == 0
        @values[i] = @values[i].to_f / other.to_f
      end
    end
    
    return self
  end
  
  def *(other)
    if other.kind_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = @values[i].to_f * other.Values[i].to_f
      end
    else
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = @values[i].to_f * other.to_f
      end
    end
    
    return self
  end
  
  
  def Assign(other)
    if other.kind_of?(Numeric) || other.kind_of?(String)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = other
      end
    elsif other.kind_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = other.Values[i]
      end
    end
    
    return self
  end
  
  def +(other)
    if other.kind_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        YtLog.info @values[i].kind_of?(Numeric)
        YtLog.info other.Values[i].class
        
        if @values[i].kind_of?(Numeric) && other.Values[i].kind_of?(Numeric)
          @values[i] = @values[i].to_f + other.Values[i].to_f
        else
          @values[i] = @values[i].to_s + other.Values[i].to_s
        end
        
        YtLog.info @values[i]
      end
    
    elsif other.kind_of?(Numeric)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = @values[i].to_f + other
      end

    elsif other.kind_of?(String)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] = @values[i].to_s + other
      end
    
    end
    
    return self
  end
  
  def -(other)
    if other.kind_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        @values[i] -= other.Values[i].to_f
      end
    else
      Integer(0).upto(@values.length-1) do |i|
        @values[i] -= other.to_f
      end
    end
    
    return self
  end
  
  def abs()
    Integer(0).upto(@values.length-1) do |i|
      @values[i] = @values[i].abs rescue nil
    end
    
    return self
  end
  
  #列对象比较，如[1] > [2]，返回结果是一个数组，里面存放true或false
  def >(other)
    result = Array.new
    
    if other.instance_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        if @values[i].kind_of?(Numeric)
            if (@values[i]||0) > other.Values[i]
              result << true
            else
              result << false
            end
        else
            if @values[i] > other.Values[i]
              result << true
            else
              result << false
            end
        end
      end
      
    else
      Integer(0).upto(@values.length-1) do |i|
        if (other.instance_of?(String) and @values[i] > other) or (other.kind_of?(Numeric) and (@values[i]||0) > other)
          result << true
        else
          result << false
        end
      end
    end
    
    result
  end
  
  #列对象比较，如[1] >= [2]，返回结果是一个数组，里面存放true或false
  def >=(other)
    result = Array.new
    
    if other.instance_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        if @values[i].kind_of?(Numeric)
            if (@values[i]||0) >= other.Values[i] || ((@values[i]||0) - other.Values[i]).abs < 0.00001
              result << true
            else
              result << false
            end
        else
            if @values[i] >= other.Values[i]
              result << true
            else
              result << false
            end
        end
      end
      
    else
      Integer(0).upto(@values.length-1) do |i|
        if (other.instance_of?(String) and @values[i] >= other) or (other.kind_of?(Numeric) and ( (@values[i]||0) <= other || ((@values[i]||0) - other).abs < 0.00001))
          result << true
        else
          result << false
        end
      end
    end
    
    result
  end
  
  #列对象比较，如[1] < [2]，返回结果是一个数组，里面存放true或false
  def <(other)
    result = Array.new
    
    if other.instance_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        if @values[i].kind_of?(Numeric)
            if (@values[i]||0) < other.Values[i]
              result << true
            else
              result << false
            end
        else
            if @values[i] < other.Values[i]
              result << true
            else
              result << false
            end
        end
      end
      
    else
      Integer(0).upto(@values.length-1) do |i|
        if (other.instance_of?(String) and @values[i] < other) or (other.kind_of?(Numeric) and (@values[i]||0) < other)
          result << true
        else
          result << false
        end
      end
    end
    
    result
  end
  
  #列对象比较，如[1] <= [2]，返回结果是一个数组，里面存放true或false
  def <=(other)
    result = Array.new
    
    if other.instance_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        if @values[i].kind_of?(Numeric)
            if (@values[i]||0) <= other.Values[i] || ((@values[i]||0) - other.Values[i]).abs < 0.00001
              result << true
            else
              result << false
            end
        else
            if @values[i] <= other.Values[i]
              result << true
            else
              result << false
            end
        end
      end
      
    else
      Integer(0).upto(@values.length-1) do |i|
        if (other.instance_of?(String) and @values[i] <= other) or (other.kind_of?(Numeric) and ( (@values[i]||0) <= other || ((@values[i]||0) - other).abs < 0.00001))
          result << true
        else
          result << false
        end
      end
    end
    
    result
  end
  
  #列对象比较，如[1] == [2]，返回结果是一个数组，里面存放true或false
  def ==(other)
    result = Array.new
    
    if other.instance_of?(FloatColumnScriptEngine)
      Integer(0).upto(@values.length-1) do |i|
        if @values[i].kind_of?(Numeric)
            if ((@values[i]||0) - other.Values[i]).abs < 0.00001
              result << true
            else
              result << false
            end
        else
            if @values[i] == other.Values[i]
              result << true
            else
              result << false
            end
        end
      end
      
    else
      Integer(0).upto(@values.length-1) do |i|
        if (other.instance_of?(String) and @values[i] == other) or (other.kind_of?(Numeric) and ((@values[i]||0) - other.Values[i]).abs < 0.00001)
          result << true
        else
          result << false
        end
      end
    end
    
    result
  end
  
  
  
  def [](*args)
    for arg in args
      if arg.kind_of?(Fixnum)
        phyRow = @table.LogicRowToPhyRow(arg)
        next if phyRow > @table.GetRowCount()   #检查是否越界
        @effect_values << arg
      end
      
      if arg.kind_of?(Range)
        for index in arg
          next if index > @values.length   #检查是否越界
          @effect_values << arg
        end
      end
    end  
    self
  end
  
  #处理类似A[1..3, 4, 5] = B + C的运算
  def []=(*args)
    i=0
    for arg in args
      if arg.kind_of?(FloatColumnScriptEngine)
        other = arg
        break 
      end
      i += 1
    end
    
    phyCol = @table.LogicColToPhyCol(@col)
    
    for arg in args
      break if arg.kind_of?(FloatColumnScriptEngine)
      if arg.kind_of?(Fixnum)
        phyRow = @table.LogicRowToPhyRow(arg)
        next if phyRow > @table.GetRowCount()   #检查是否越界
        field = @table.GetCellDBFieldName(phyRow, phyCol)
        @record[field] = other.Values[arg-1]
      end
      
      if arg.kind_of?(Range)
        for index in arg
          next if index > @values.length   #检查是否越界
          phyRow = @table.LogicRowToPhyRow(index)
          field = @table.GetCellDBFieldName(phyRow, phyCol)
          @record[field] = other.Values[index-1]
        end
      end
    end
  end
end




