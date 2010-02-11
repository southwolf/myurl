class CreateScalarexplain < ActiveRecord::Migration
  def self.up
    create_table :ytapl_scalarexplain, :primary_key => :id do |t|
       t.column :name, :string, :limit=>100
       t.column :content, $TEXT
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_scalarexplain 
  end
end
