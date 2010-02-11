class CreateYtaplConverttask < ActiveRecord::Migration
  def self.up
    create_table :ytapl_converttask, :primary_key => :id do |t|
       t.column :taskid, :integer
       t.column :name, :string, :limit=>100
       t.column :publishtime, :date
       t.column :content, $TEXT
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
       t.column :reserved4, :string, :limit=>100
       t.column :reserved5, :string, :limit=>100
       t.column :reserved6, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_converttask
  end
end
