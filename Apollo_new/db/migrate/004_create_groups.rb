class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :ytapl_groups, :primary_key => :groupid do |t|
       t.column :name, :string, :limit=>100, :null=>true
       t.column :datecreated, :datetime
       t.column :datemodified, :datetime
       t.column :flag, :integer
       t.column :memo, :string, :limit=>100
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
    group = YtaplGroup.new
    group.id = 1
    group.name = '管理员'
    group.memo = '负责系统管理'
    group.datecreated = Time.new
    group.flag = 0
    group.save
  end

  def self.down
    drop_table :ytapl_groups
  end
end
