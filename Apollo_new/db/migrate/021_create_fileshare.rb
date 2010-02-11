class CreateFileshare < ActiveRecord::Migration
  def self.up
    create_table :ytapl_fileshare, :primary_key => :id do |t|
       t.column :userid, :string, :limit=>100, :null=>true
       t.column :name, :string, :limit=>100
       t.column :sender, :string, :limit=>100
       t.column :uploadtime, :datetime
       t.column :path, :string, :limit=>200
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_fileshare
  end
end
