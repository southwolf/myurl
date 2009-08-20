class CreateRecent < ActiveRecord::Migration
  def self.up
    create_table :recents do |t|
      t.column :user_id, :integer
      t.column :kind, :integer          #1:收藏 2:分享  
      t.column :site_id, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :recents
  end
end
