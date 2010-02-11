class SetOfPrivileges
  
  def initialize()
  end
  
  class << self        
	Right_array = ["管理用户", 
                    "管理任务", 
                    "管理报表",
                    "数据汇总", 
                    "查看填报情况", 
                    "强制导入过期数据", 
                    "数据审核", 
                    "管理通知", 
                    "删除留言", 
                    "查看底层单位数据",
                    "删除单位数据",
		            "写入审核标志", 
		            "", 
		            "", 
		            "", 
		            "",
		            "", 
		            "", 
		            "", 
		            "", 
		            "",
		            "",
		            "", 
		            "", 
		            "", 
		            "",
		            "", 
		            "", 
		            "", 
		            "", 
		            "",
		            "", 
		            ""];

      Desc_array = ["增加、修改、删除用户、组和角色，以及为用户、组分配资源访问权限",
		          "发布、删除任务，表样，脚本，选择汇总方案以及代码字典",
		          "上报数据，指标查询",
		          "进行数据汇总",
		          "查看填报情况",
		          "强制导入数据，无论数据是否过期",
		          "对填写的报表数据进行审核",
		          "对通知、消息进行管理",
		          "对于含有不良语言的留言进行删除", 
		          "高级用户可查看单户企业的数据", 
		          "不需要企业填某期数据而企业又误填了数据，可以删除单位数据", 
		          "标记什么时候什么人对企业上报的数据进行了审核", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          "", 
		          ""];
		          
	Right_size = 12 
    
    def size
      Right_size
    end  
    
    def [](index)
      Right_array[index]
    end  
    
    def desc(index)
      Desc_array[index]
    end
    
    def get_right_index(right)
    	Integer(0).upto(12) do |i|
      		if Right_array[i] == right.to_s
        		return i
      		end
    	end
    	-1
    end
  end

  #instance
  def initialize
    @right_str = "F"*32
  end
  
  def text=(other)
    @right_str = other
  end
  
  def text
  	@right_str
  end
  
  def []=(index, flag)
    if flag
      @right_str[index] = 'T'
    else
      @right_str[index] = 'F'
    end
  end
  
  def [](index)
    if @right_str[index,1] == 'T' || @right_str[index,1] == 't'
      return true
    else
      return false
    end
  end
  
  def check(right)
    index = SetOfPrivileges.get_right_index(right)
    return  self[index]#@right_str[index, 1] == 'T' || @right_str[index, 1] == 't'
  end
end