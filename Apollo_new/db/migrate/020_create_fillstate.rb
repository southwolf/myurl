class CreateFillstate < ActiveRecord::Migration
  def self.up
    create_table :ytapl_fillstate, :id => false do |t|
       t.column :unitid, :string, :limit=>50, :null=>true
       t.column :taskid, :string, :limit=>50, :null=>true
       t.column :tasktimeid, :integer
       t.column :filldate, :datetime
       t.column :flag, :integer
       t.column :ext1, :integer
       t.column :ext2, :integer
       t.column :ext3, :integer
       t.column :ext4, :integer
    end
  end

  def self.down
    drop_table :ytapl_fillstate
  end
end
