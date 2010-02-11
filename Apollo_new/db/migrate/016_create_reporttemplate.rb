class CreateReporttemplate < ActiveRecord::Migration
  def self.up
    create_table :ytapl_report_template, :primary_key => :templateid do |t|
       t.column :taskid, :string, :limit=>50
       t.column :templatename, :string, :limit=>50
       t.column :createtime, :datetime
       t.column :moditime, :datetime
       t.column :content, $TEXT
       t.column :image, $TEXT
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
       t.column :reserved4, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_report_template
  end
end
