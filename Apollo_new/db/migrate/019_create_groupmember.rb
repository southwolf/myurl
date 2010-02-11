class CreateGroupmember < ActiveRecord::Migration
  def self.up
    create_table :ytapl_groupmember, :id => false do |t|
       t.column :groupid, :integer
       t.column :userid, :integer
    end
    member = Ytgroupmember.new
    member.groupid = 1
    member.userid = 1
    member.save
  end

  def self.down
    drop_table :ytapl_groupmember
  end
end