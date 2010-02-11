class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :ytapl_tasks, :primary_key => :taskid do |t|
       t.column :strid, :string, :limit=>20
       t.column :name, :string, :limit=>100, :null=>true
       t.column :version, :integer
       t.column :flag, :integer
       t.column :datecreated, :datetime
       t.column :datemodified, :datetime
       t.column :memo, :string, :limit=>200
       t.column :content, $TEXT
       t.column :activescriptsuitname, :string, :limit=>100
       t.column :position, :integer
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_tasks
  end
end
