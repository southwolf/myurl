class CreateRecommands < ActiveRecord::Migration
  def self.up
    create_table :recommands do |t|
      t.column :address, :string, :limit=>250
      t.column :name, :string, :limit=>200
      t.column :label_id, :integer
      t.column :user_id, :integer           #谁提交了这个网页
      t.column :adopt_count, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :recommands
  end
end
