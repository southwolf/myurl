class CreateStatistic < ActiveRecord::Migration
  def self.up
    create_table :ytapl_statistic, :primary_key => :id do |t|
       t.column :cata_id, :integer, :null=>true
       t.column :name, :string, :limit=>100
       t.column :uploadtime, :datetime
       t.column :path, :string, :limit=>100
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_statistic
  end
end
