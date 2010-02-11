class CreateUnitpermission < ActiveRecord::Migration
  def self.up
    create_table :ytapl_unitpermissions, :id => false do |t|
       t.column :groupid, :integer
       t.column :taskid, :string, :limit=>50, :null=>true
       t.column :unitid, :string, :limit=>50, :null=>true
       t.column :permission, :integer
       t.column :endtime, :datetime
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_unitpermissions
  end
end
