class CreateDataevents < ActiveRecord::Migration
  def self.up
    create_table :ytapl_dataevents, :primary_key => :eventid do |t|
       t.column :timeoccured, :datetime
       t.column :eventtype, :integer
       t.column :source, :string, :limit=>100
       t.column :username, :string, :limit=>100
       t.column :memo, :text
    end
  end

  def self.down
    drop_table :ytapl_dataevents
  end
end
