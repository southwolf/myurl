class CreateYtaplRoleright < ActiveRecord::Migration
  def self.up
    create_table :ytapl_roleright, :id => false do |t|
       t.column :role_id, :integer
       t.column :right_id, :integer
    end
  end

  def self.down
    drop_table :ytapl_roleright
  end
end
