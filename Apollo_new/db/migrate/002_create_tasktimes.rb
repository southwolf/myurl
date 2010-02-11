class CreateTasktimes < ActiveRecord::Migration
  def self.up
    create_table :ytapl_tasktimes, :primary_key => :tasktimeid do |t|
       t.column :taskid, :integer
       t.column :begintime, :datetime
       t.column :endtime, :datetime
       t.column :submitbegintime, :datetime
       t.column :submitendtime, :datetime
       t.column :attentionbegintime, :datetime
       t.column :attentionendtime, :datetime
       t.column :flag, :integer
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_tasktimes
  end
end
