class CreateBrowselog < ActiveRecord::Migration
  def self.up
    create_table :ytapl_browselog, :primary_key => :id do |t|
       t.column :news_id, :integer
       t.column :username, :string, :limit=>100
       t.column :browsetime, :datetime
       t.column :address, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_browselog
  end
end
