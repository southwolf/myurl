class CreateScript < ActiveRecord::Migration
  def self.up
    create_table :ytapl_script, :primary_key => :scriptid do |t|
       t.column :taskid, :integer
       t.column :publishtime, :datetime
       t.column :name, :string, :limit=>100
       t.column :content, $TEXT
    end
  end

  def self.down
    drop_table :ytapl_script
  end
end
