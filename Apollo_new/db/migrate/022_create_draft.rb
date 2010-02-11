class CreateDraft < ActiveRecord::Migration
  def self.up
    create_table :ytapl_draft, :primary_key => false do |t|
       t.column :unitid, :string, :limit=>100, :null=>true
       t.column :taskid, :integer
       t.column :tasktimeid, :integer
       t.column :content, $TEXT
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
  end

  def self.down
    drop_table :ytapl_draft
  end
end
