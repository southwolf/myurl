module MainHelper
  def change_currency_base(str)
   begin 
    if str.size == 1
      '元'
    elsif str.size == 3
      '百元'
    elsif str.size == 4
      '千元'
    elsif str.size == 5
      '万元'
    elsif str.size == 9
      '亿元'
    else
      '万元'
    end
   rescue
    '万元'
   end 
  end
  
  #判断某个任务某个单位某期数据是否封存
  #返回true表示封存，false表示未封存
  def GetEnvolopState(taskstrid, tasktimeid, unitid)
    Ytfillstate.set_table_name(:ytapl_fillstate)
    states = Ytfillstate.find(:all, :conditions => "taskid = '#{taskstrid}' and unitid = '#{unitid}' and tasktimeid = #{tasktimeid}")
    if states.length > 0
      state = states[0]
	  if state.flag == 4
	     return false
	  else
	     return true
	  end
    else
      return false
    end
  end
  
end
