class SetOfPrivileges
  
  def initialize()
  end
  
  class << self        
	Right_array = ["�����û�", 
                    "��������", 
                    "������", 
                    "ִ��ѡ����ܷ���", 
                    "�鿴����", 
                    "ǿ�Ƶ����������", 
                    "���", 
                    "����֪ͨ", 
                    "ɾ������", 
                    "�鿴�ײ㵥λ����",
                    "ɾ����λ����",
		            "д����˱�־", 
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

      Desc_array = ["���ӡ��޸ġ�ɾ���û�����ͽ�ɫ���Լ�Ϊ�û����������Դ����Ȩ��",
		          "������ɾ�����񣬱������ű���ѡ����ܷ����Լ������ֵ�",
		          "�ϱ����ݣ�ָ���ѯ�ͻ���",
		          "ִ��ѡ����ܷ���",
		          "�鿴����",
		          "ǿ�Ƶ������ݣ����������Ƿ����",
		          "�������",
		          "��֪ͨ����Ϣ���й���",
		          "���ں��в������Ե����Խ���ɾ��", 
		          "�߼��û��ɲ鿴������ҵ������", 
		          "����Ҫ��ҵ��ĳ�����ݶ���ҵ�����������ݣ�����ɾ����λ����", 
		          "���ʲôʱ��ʲô�˶���ҵ�ϱ������ݽ��������", 
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