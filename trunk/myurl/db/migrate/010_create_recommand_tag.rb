class CreateRecommandTag < ActiveRecord::Migration
  def self.up
    create_table :recommand_tag, :id=>false do |t|
      t.column :recommand_id, :integer
      t.column :tag_id, :integer
    end
  end

  def self.down
    drop_table :recommand_tag
  end
end
