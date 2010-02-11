class CreateAddressinfo < ActiveRecord::Migration
  def self.up
    create_table :ytapl_addressinfo, :primary_key => :id do |t|
       t.column :taskid, :string, :limit=>100, :null=>true
       t.column :unitid, :string, :limit=>100, :null=>true
       t.column :email, :string, :limit=>100
       t.column :mobile, :string, :limit=>100, :null=>true
       t.column :phone, :string, :limit=>100, :null=>true
       t.column :fax, :string, :limit=>100, :null=>true
       t.column :flag, :integer
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100       
    end
  end

  def self.down
    drop_table :ytapl_addressinfo
  end
end
