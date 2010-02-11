class CreateReportresult < ActiveRecord::Migration
  def self.up
    create_table :ytapl_reportresult, :primary_key => :id do |t|
       t.column :templateid, :integer
       t.column :name, :string, :limit=>100
       t.column :createtime, :datetime
       t.column :context, $TEXT
    end
  end

  def self.down
    drop_table :ytapl_reportresult
  end
end
