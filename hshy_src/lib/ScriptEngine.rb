class TaskScriptEngine
  attr_reader :taskstrid, :unitid
  #��ʼ������ű�����
  #taskstrid:����id����QYKB
  #script:   �ű���CTaskScriptʵ��
  #unitid:   ��λid����1111111117
  #tasktime: ����ʱ�䣬Time����
  #tables:   �����飬Ԫ��ΪCTableʵ��
  #records:  �������飬ActiveRecord::Baseʵ��
  #sum_mode: ����ģʽ��������ģʽ�£�û�з����
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

  #ִ��ĳ�ű�����㹫ʽ
  def ExecuteCalc(tablename)    
    YtLog.info "Execute calc script of " + tablename
    in_table = false
    for element in @table_script_engines
      if tablename.downcase == element.TableName().downcase
        YtLog.info "dispatch to #{element.TableName}"
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
  
  #ִ��ĳ�ű����˹�ʽ, ���tablenameΪ����ִ�б����˹�ʽ
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
    YtLog.info lines, 'lines'
    if lines
      lines.each { |line|
#        YtLog.info(line)
        next if !line || line.strip().size <1
        @current_table_script.current_audit_text = extract_script(line) #������˹�ʽ���ı������Ա�鿴�ֳ�
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
  
  #��audit(a>b,'aҪ����b'�� _a, _b)�����Ĺ�ʽ�г�ȡ��"a>b"�����Ĺ�ʽ
  def extract_script(line)
    #line = line[0, line.index('//')]    
    
    text = line.gsub(/audit\s*\(/, "")
    text = text.gsub(/warn\s*\(/, "")
    line = text[0, text.index(',')]  if text.index(',')
    YtLog.info line
    line
  end
  
  #����˹�ʽ����Ԥ����
  def predeal_calc(line)
    #��a=b+qybb.c����Ϊself.a=self.b+self.qybb.c
    #line = line.gsub(/[a-zA-Z]\w*/, 'self.\0')
    #line = line.gsub(/(self.)(if|then|else|elsif|nil|when|def|false|true|while|do|end|return|break|next|for|self|class|ensure|until|yield)/, '\2')
    
    #��"[1] = [2]"����Ϊself[1] = self[2]
    line = line.gsub(/^([\[.*\]])/, 'self\0')             
    line = line.gsub(/([\W^])(\[\d*\])/, '\1self\2')    
    
    YtLog.info(line)
    line
  end
  
  
  #����˹�ʽ����Ԥ�������[1] = [2] ���self[1] = self[2]
  def predeal_audit(line)    
    #��"[1] = [2]"����Ϊself[1] = self[2]
    text = line.gsub(/^([\[.*\]])/, 'self\0')             #�滻�����[1]
    text = text.gsub(/([\W^])(\[\d*\])/, '\1self\2')
    text = text.gsub(/(self.)(if|then|else|elsif|nil|when|def|false|true|while|do|end|return|break|next|for|self|class|ensure|until|yield)/, '\2')
    
    #��#1 ����Ϊ self[1]
    text = text.gsub(/(#)(\d+)/, 'self[\2]')
    
    return text
    
    text = text.gsub(/(.*)(>=|<=|==|>|<)(.*)(\/\/)(.*)/, 'audit(\1 \2 \3, "\5"')    #��"[1] > [2]//��һ�д��ڵڶ���"����Ϊaudit([1]>[2], "��һ�д��ڵڶ���")
    #���Ҳ���[18]����Ϊ_18
	line.gsub(/\B(\[)(\d*)(\])/){|row|
		text += ",_" + row[1, row.size-2]
	}
	
	#���Ҳ���qykb[18]����Ϊqykb._18
	line.gsub(/(\w)+\[(\d*)\]/){|row|
		text += "," + row.gsub("[", "._").gsub("]", "")
	}
	
	#���Ҳ���a����Ϊ_a
	
	#���Ҳ���qykb.a1����Ϊqykb._a1
	line.gsub(/\w+\.\w+/){|cell|
		text += "," + cell.gsub(".", "._")
	}
	
	#���Ҳ���a1����Ϊ_a1
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
  
  #ִ�����б�����㹫ʽ
  def ExecuteAllCalc()
      for table in @tables
        begin
        ExecuteCalc(table.GetTableID())
        rescue
        end
      end
      ExecuteCalc("")
     
     #����������ƽ̨����������
#     for element in @table_script_engines
#      if 1#element.changed?  
#        if element.IsFaceTable()
#          UnitFMTableData.set_table_name("ytapl_#{@taskstrid}_#{element.TableName()}")
#          UnitFMTableData.reset_column_information
#        else
#          UnitTableData.set_table_name("ytapl_#{@taskstrid}_#{element.TableName()}")
#          UnitTableData.reset_column_information
#        end
#        element.TableRecord().save 
#      end
#    end
  end
  
  #ִ�����б����˹�ʽ
  def ExecuteAllAudit()
    @errors = Array.new
    @warns = Array.new
      
    for table in @tables
        ExecuteAudit(table.GetTableID(), false)
    end
    
    #������ƽ̨�����乫ʽ
    #ExecuteAudit("", false)
  end

  
  def GetErrors()
    @errors
  end
  
  def GetWarns()
    @warns
  end
  
  #���ع�ʽ��������
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

  #�����������ǰ��׼��
  def Prepare
    for element in @table_script_engines
      element.SetOutTables(@table_script_engines)
      element.Prepare
    end
  end
end

#��ʽ��������
class TableScriptEngine
  attr_accessor :current_audit_text
  #record������ActiveRecord������һ����λ��һ�ű������
  #tasktime��Time����,��ʾ���ڵ�����
  def initialize(table, record, isface, tasktime, task)
    @table = table
    @record = record
    @changed = false
    @isface = isface
    @audit_error = Array.new
    @audit_warn = Array.new
    @tasktime = tasktime
    @task = task
    
    #��ǰ��˵Ĺ�ʽ
    @current_audit_text = ""
    
    #p @record
    
    for field in record.attribute_names() 
      #Ϊÿ���ֶζ���һ����������a1=, b3=      
      instance_eval("def #{field.downcase()}=(other)
                      for field1 in @record.attribute_names()
                        if field1.downcase() == '#{field}'.downcase()            
                          p \"\#{field1}\"
                          p other
                          @record[\"\#{field1}\"] = other 
                          @changed = true
                          return
                        end
                      end        
                     end")
                     
      #ͬʱ��Ҫ����_a1, _a2�����ĺ���������'zbb.a1', 'FM.b1'�������ַ����������������ʱ��Ĵ���λ
      instance_eval("def _#{field.downcase()}()                      
                      return '#{@table.GetTableID()}.#{field}'      
                     end")
    end
    
    #�����ж�λ��ʽ��_1, _2������һ������,����Ԫ����_a1, _b1, _c1
    Integer(0).upto(@table.GetRowCount()-1) do |row|
        next if @table.IsEmptyRow(row)
        logicRow = @table.PhyRowToLogicRow(row+1)
        
        script = ""
        Integer(0).upto(@table.GetColumnCount()-1) do |col|
            next if @table.IsEmptyCol(col)
            logicCol = @table.PhyColToLogicCol(col+1)
            script += "result << _#{(logicCol + 64).chr.downcase}#{logicRow}"
            script += "\n"
        end
        
        instance_eval("def _#{logicRow}()
                          result = Array.new
                          #{script}
                          result
                       end")    
    end                   
      
    
    
    #Ϊÿ�ж���һ����������A=, B=, D=
    index = 1
    Integer(0).upto(@table.GetColumnCount-1) do |col|
      next if @table.IsEmptyCol(col)

      instance_eval("def #{(index+64).chr.downcase}= (other)
                      SetColValue(#{index}, other)      
                    end")
      
      index += 1
    end
    
    #Ϊÿ�ж��嶨λ��������_a,_b,����һ������,����Ԫ����_a1, _a2, _a3
    Integer(0).upto(@table.GetColumnCount()-1) do |col|
      next if @table.IsEmptyCol(col)
      logicCol = @table.PhyColToLogicCol(col+1)
      
      script = ""
      Integer(0).upto(@table.GetRowCount()-1) do |row|
            next if @table.IsEmptyRow(row)
            logicRow = @table.PhyRowToLogicRow(row+1)
            script += "result << _#{(logicCol + 64).chr.downcase}#{logicRow}"
            script += "\n"
      end
 
      instance_eval("def _#{(logicCol + 64).chr.downcase}()
                          result = Array.new
                          #{script}
                          result
                       end")    
    end
    
    #p @record
  end
  
  #�����ⲿ�����飬Ԫ��������TableScriptEngine������������T1���з���T2��
  def SetOutTables(others)
    @out_tables = others
  end
  
  #��ʼ��,Ϊÿ�ű�����������t2(), t3()
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
  
  #�����˴���
  def errors
    @audit_error
  end
  
  #��þ����ʹ���
  def warns
    @audit_warn
  end
  
  #��ˣ�������Ϣ�����@audit_error�����У�ÿ��Ԫ������һ�����飬Ԫ��0��Ŵ�����Ϣ��Ԫ��1����һ�����飬������ж�λ��Ԫ�񣬴�����ж�λ��Ԫ��Ԫ��2��Ź�ʽ
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
  
  #��������ˣ�������Ϣ�����@audit_error�����У�ÿ��Ԫ������һ�����飬Ԫ��0��Ŵ�����Ϣ��Ԫ��1����һ�����飬������ж�λ��Ԫ��Ԫ��2��Ź�ʽ
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
  
  #�����˴���,������Ϣ�����@audit_error�����У�ÿ��Ԫ������һ�����飬Ԫ��0��Ŵ�����Ϣ��Ԫ��1����һ�����飬������ж�λ��Ԫ��
  def GetAuditError()
    @audit_error
  end
  
  #col���߼��к�, other����һ��ColumnScriptEngine
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
  
  #���и�ֵ�ĺ�����args[0]Ϊ�кţ�args[1]Ϊ��һ��RowScriptEngine����
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
  
  #�Ƿ�����
  def IsFaceTable()
    @isface
  end
  
  #�Ƿ��Ѹı䣬���û���򲻲������ݿ⣬��ʡ���ݿ����
  def changed?
    @changed
  end
  
  #�����ﷵ�ص�Ԫ������ݣ�����Ҳ����򷵻�0
  def method_missing(method_id, *args) 
    name = method_id.id2name.to_s.downcase
    
    if name == 'task'
      return @task
    end
    
    #�ж��Ƿ��ǵ�Ԫ�����, ��a1, c2. ����ֵ����0
    for field in @record.attribute_names()
      if field.downcase == name
        if @record["#{field}"] == nil
          return 0
        else
          return @record["#{field}"]
        end        
      end 
    end
    
    #�ж��Ƿ����в���,��[1], [3]
    if name == "[]"
      row = RowScriptEngine.new(@table, args[0], @record)
      #YtLog.info "scriptrow created" + args[0].to_s
      return row
    end
    
    #�ж��Ƿ����в���, ��a, b
    Integer(0).upto(@table.GetColumnCount-1) do |col|
      next if @table.IsEmptyCol(col)
      logicCol = @table.PhyColToLogicCol(col+1)
      if (logicCol+64).chr.downcase == name.downcase()
        #YtLog.info "new column script created\nname is #{name}\nlogicCol is #{logicCol}"
        #YtLog.info @table.GetTableID()
        return ColumnScriptEngine.new(@table, logicCol, @record)
      end
    end
    
    return 0
  end
end

#��ʽ�����ж��󣬴���һ�ű��ĳһ�л���һ�е�һ�����֣���T1[1], [1], [9][A, D], [5][a..b, e..f, g, h].. 
class RowScriptEngine
  #rowΪ�߼���
  def initialize(table, row, record)
    @row = row
    @table = table
    @record = record
    @values = Array.new
    @effect_values = Array.new
    @valid = Array.new  #��ɢ��ʽʹ�ã���ʾ��Ч�ĵ�
    
    #�߼���ת��������
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
  
  #�ж���Ƚϣ���[1] > [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] >= [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] < [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] <= [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] == [2]�����ؽ����һ�����飬������true��false
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

  #��������[1][1..3, 4, 5] = [2] + [3]
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
        next if phyCol > @table.GetColumnCount()   #����Ƿ�Խ��
        field = @table.GetCellDBFieldName(phyRow, phyCol)
        @record[field] = other.Values[arg-1]
      end
      
      if arg.kind_of?(Range)
        for index in arg
          phyCol = @table.LogicColToPhyCol(index)
          next if phyCol > @table.GetColumnCount()   #����Ƿ�Խ��
          field = @table.GetCellDBFieldName(phyRow, phyCol)
          @record[field] = other.Values[index-1]
        end
      end
    end
  end
end

#��ʽ�����ж��󣬴���һ�ű��ĳһ�л���һ�е�һ�����֣���T1.A, B, D[1, 5], E[1..3, 5..8, 9]..
class ColumnScriptEngine
  #colΪ�߼���
  def initialize(table, col, record)
    @col = col
    @table = table
    @record = record
    @values = Array.new
    @effect_values = Array.new
    
    #�߼���ת��������
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
  
  #�ж���Ƚϣ���[1] > [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] >= [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] < [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] <= [2]�����ؽ����һ�����飬������true��false
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
  
  #�ж���Ƚϣ���[1] == [2]�����ؽ����һ�����飬������true��false
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
        next if phyRow > @table.GetRowCount()   #����Ƿ�Խ��
        @effect_values << arg
      end
      
      if arg.kind_of?(Range)
        for index in arg
          next if index > @values.length   #����Ƿ�Խ��
          @effect_values << arg
        end
      end
    end  
    self
  end
  
  #��������A[1..3, 4, 5] = B + C������
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
        next if phyRow > @table.GetRowCount()   #����Ƿ�Խ��
        field = @table.GetCellDBFieldName(phyRow, phyCol)
        @record[field] = other.Values[arg-1]
      end
      
      if arg.kind_of?(Range)
        for index in arg
          next if index > @values.length   #����Ƿ�Խ��
          phyRow = @table.LogicRowToPhyRow(index)
          field = @table.GetCellDBFieldName(phyRow, phyCol)
          @record[field] = other.Values[index-1]
        end
      end
    end
  end
end