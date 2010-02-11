class CreateUnitschema < ActiveRecord::Migration
  def self.up
    create_table :ytapl_unitschema, :primary_key => :groupid do |t|
       t.column :taskid, :integer, :null=>true
       t.column :name, :string, :limit=>100, :null=>true
       t.column :content, $TEXT 
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_unitschema
  end
end
