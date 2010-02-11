class CreateAuditinfo < ActiveRecord::Migration
  def self.up
    create_table :ytapl_auditinfo, :id => false do |t|
       t.column :unitid, :string, :limit=>100, :null=>true
       t.column :taskid, :string, :limit=>100, :null=>true
       t.column :tasktimeid, :integer
       t.column :auditdate, :datetime
       t.column :flag, :integer
       t.column :auditor, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_auditinfo
  end
end
