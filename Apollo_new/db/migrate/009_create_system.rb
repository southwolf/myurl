class CreateSystem < ActiveRecord::Migration
  def self.up
    create_table :ytapl_system, :primary_key => :id do |t|
       t.column :visitedtimes, :integer, :null=>true
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
       t.column :reserved4, :string, :limit=>100
       t.column :reserved5, :string, :limit=>100
       t.column :reserved6, :string, :limit=>100
    end
    s = YtaplSystem.new
    s.visitedtimes = 0
    s.save
  end

  def self.down
    drop_table :ytapl_system
  end
end
