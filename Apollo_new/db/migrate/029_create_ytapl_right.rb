class CreateYtaplRight < ActiveRecord::Migration
  def self.up
    create_table :ytapl_right, :primary_key => :id do |t|
       t.column :name, :string, :limit=>100
       t.column :memo, :string, :limit=>100
    end
    
    right = YtaplRight.new
    right.name = "管理用户"
    right.desc = "增加、修改、删除用户、组和角色，以及为用户、组分配资源访问权限"
    right.save
    
    right = YtaplRight.new
    right.name = "管理任务"
    right.desc = "发布、删除任务，表样，脚本，选择汇总方案以及代码字典"
    right.save
    
    right = YtaplRight.new
    right.name = "数据汇总"
    right.desc = "进行数据汇总"
    right.save
    
    right = YtaplRight.new
    right.name = "查看填报情况"
    right.desc = "查看填报情况"
    right.save
    
    right = YtaplRight.new
    right.name = "强制导入过期数据"
    right.desc = "强制导入数据，无论数据是否过期"
    right.save
    
    right = YtaplRight.new
    right.name = "数据审核"
    right.desc = "对填写的报表数据进行审核"
    right.save
    
    right = YtaplRight.new
    right.name = "管理通知"
    right.desc = "对通知、消息进行管理"
    right.save
    
    right = YtaplRight.new
    right.name = "删除留言"
    right.desc = "对于含有不良语言的留言进行删除"
    right.save
    
    right = YtaplRight.new
    right.name = "查看底层单位数据"
    right.desc = "高级用户可查看单户企业的数据"
    right.save
    
    right = YtaplRight.new
    right.name = "删除单位数据"
    right.desc = "不需要企业填某期数据而企业又误填了数据，可以删除单位数据"
    right.save
    
    right = YtaplRight.new
    right.name = "写入审核标志"
    right.desc = "标记什么时候什么人对企业上报的数据进行了审核"
    right.save
    
    right = YtaplRight.new
    right.name = "数据备份"
    right.desc = "进行数据备份和数据恢复操作"
    right.save
  end

  def self.down
    drop_table :ytapl_right
  end
end
