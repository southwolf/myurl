class CreateTaskvisible < ActiveRecord::Migration
  def self.up
    create_table :ytapl_taskvisible, :id => false do |t|
       t.column :taskid, :integer
       t.column :groupid, :integer
    end
  end

  def self.down
    drop_table :ytapl_taskvisible
  end
end
