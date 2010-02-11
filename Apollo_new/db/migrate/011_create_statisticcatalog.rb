class CreateStatisticcatalog < ActiveRecord::Migration
  def self.up
    create_table :ytapl_statisticcatalog, :primary_key => :id do |t|
       t.column :name, :string, :limit=>100
       t.column :parent_id, :integer
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_statisticcatalog
  end
end