class CreateBbsmessage < ActiveRecord::Migration
  def self.up
    create_table :ytapl_bbsmessage, :primary_key => :id do |t|
       t.column :username, :string, :limit=>50, :null=>true
       t.column :time, :datetime
       t.column :title, :string, :limit=>200, :null=>true
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
    drop_table :ytapl_bbsmessage
  end
end
