class CreateCookies < ActiveRecord::Migration
  def self.up
    create_table :ytapl_cookies, :primary_key => :id do |t|
       t.column :addr, :string, :limit=>50, :null=>true
       t.column :lasttask, :integer
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
       t.column :reserved4, :string, :limit=>100
       t.column :reserved5, :string, :limit=>100
       t.column :reserved6, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_cookies
  end
end
