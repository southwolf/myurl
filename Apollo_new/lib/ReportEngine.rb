require "Const"
require "ReportDataSource"
require "ReportResult"

class ReportEngine
    def GetFillType(pDesignTable)
	Integer(0).upto(pDesignTable.GetRowCount()-1) do |row|
	    Integer(0).upto(pDesignTable.GetColumnCount()-1) do |col|
		pCell= pDesignTable.GetCell(row, col);
		next if(!pCell.IsEffective() || !pCell.IsStore())
		
		fill= ReportUtil::GetCellFill(pCell);
		return fill if(fill != FILL_NONE)
            end
	end

	return FILL_NONE;
    end

    def fill(table, sql, script=nil)
        #pQueryValue = table.dup
        pQueryValue = CTable.new(StyleManager.new, "table1", "财务表")
        pQueryValue.Copy(table)
        reportResults = ReportResult.new(table, GetFillType(table))
        ds = ReportDataSource.new()
        
        time1 = Time.new
        ds.Query(sql)
        time2 = Time.new
        YtLog.info time2-time1, '获得数据花费时间'
        YtLog.info ds.GetRecordCount, '获得记录数'
        
        index = 0
        
        #执行公用脚本        
        ds.instance_eval(script.getCommonScript) if script

        while ds.Next
            #条件过滤
            if script && script.getAuditScript(table.GetTableID()).gsub(' ','').size > 0
                next if !table.instance_eval(script.getAuditScript(table.GetTableID()))
            end
            
            index += 1
            pQueryValue.ClearDataArea()
            if(reportResults.GetFillType() == FILL_VERTICAL)
                Integer(0).upto(table.GetRowCount()-1) do |row|
                    Integer(0).upto(table.GetColumnCount()-1) do |col|
                        cell = table.GetCell(row, col)
                        next if !cell.IsEffective() || !cell.IsStore()

                        csValue = ds.instance_eval(cell.GetText())
                        break if csValue == "" && ReportUtil::GetCellFill(cell) == FILL_VERTICAL
                        pQueryValue.SetCellValue(row, col, EncodeUtil.change("GB2312", "UTF-8", csValue.to_s))
                    end
                end
            elsif(reportResults.GetFillType() == FILL_HORIZONTAL)
                Integer(0).upto(table.GetColumnCount()-1) do |col|
                    Integer(0).upto(table.GetRowCount()-1) do |row|
                        cell = table.GetCell(row, col)
                        next if !cell.IsEffective() || !cell.IsStore()
                        
                        csValue = ds.instance_eval(cell.GetText())
                        break if csValue == "" && ReportUtil::GetCellFill(cell)==FILL_HORIZONTAL
                        pQueryValue.SetCellValue(row, col, EncodeUtil.change("GB2312", "UTF-8", csValue.to_s))
                    end
                end
            else
                Integer(0).upto(table.GetRowCount()-1) do |row|
                    Integer(0).upto(table.GetColumnCount()-1) do |col|
                        cell = table.GetCell(row, col)
                        next if !cell.IsEffective() || !cell.IsStore()                        
                        
                        csValue = ds.instance_eval(cell.GetText())
                        pQueryValue.SetCellValue(row, col, EncodeUtil.change("GB2312", "UTF-8", csValue.to_s))
                    end
                end
            end
            
            reportResults.AppendValue(pQueryValue)
            #print ds.jm + "\n"
        end

        time3 = Time.new
        YtLog.info time3-time1, '遍历完数据花费时间'
        result = reportResults.CreateResultTable()
        
        time4 = Time.new
        YtLog.info time4-time1, '构造最终结果花费时间'
    
        #最后的运算公式
        if script && script.getCalcScript(table.GetTableID())
            result.instance_eval(script.getCalcScript(table.GetTableID()))
        end
        
        result
    end
end
