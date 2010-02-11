class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :ytapl_roles, :primary_key => :roleid do |t|
       t.column :name, :string, :limit=>100, :null=>true
       t.column :userrights, :string, :limit=>100, :null=>true
       t.column :datecreated, :datetime
       t.column :datemodified, :datetime
       t.column :flag, :integer
       t.column :memo, :string, :limit=>100
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
    role1 = YtaplRole.new
    role1.id = 1
    role1.name = '管理员角色'
    role1.userrights = 'tttttttttttttttttttttttttttttttt'
    role1.memo = '负责系统管理'
    role1.flag = 0
    role1.save
    
    role2 = YtaplRole.new
    role2.id = 2
    role2.name = '填报者角色'
    role2.userrights = 'fftfffffffffffffffffffffffffffff'
    role2.memo = '负责填报'
    role2.flag = 0
    role2.save
    
    role3 = YtaplRole.new
    role3.id = 3
    role3.name = '数据分析员'
    role3.userrights = 'fftttfffffffffffffffffffffffffff'
    role3.memo = '数据分析'
    role3.flag = 0
    role3.save
  end

  def self.down
    drop_table :ytapl_roles
  end
end
