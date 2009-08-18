class CreateRecommandTags < ActiveRecord::Migration
  def self.up
    create_table :recommand_tags do |t|
    end
  end

  def self.down
    drop_table :recommand_tags
  end
end
