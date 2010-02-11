class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :ytapl_users, :primary_key => :userid do |t|
       t.column :name, :string, :limit=>100, :null=>true
       t.column :truename, :string, :limit=>100
       t.column :password, :string, :limit=>100
       t.column :roleid, :string, :limit=>100
       t.column :enterprisename, :string, :limit=>100
       t.column :lawpersioncode, :string, :limit=>100
       t.column :lawpersionname, :string, :limit=>100
       t.column :lawpersionphone, :string, :limit=>100
       t.column :contactpersionname, :string, :limit=>100
       t.column :contactpersionphone, :string, :limit=>100
       t.column :contactpersionmobile, :string, :limit=>100
       t.column :contactaddress, :string, :limit=>100
       t.column :postcode, :string, :limit=>100
       t.column :email, :string, :limit=>100
       t.column :fax, :string, :limit=>100
       t.column :datecreated, :datetime
       t.column :datemodified, :datetime
       t.column :flag, :integer
       t.column :memo, :string, :limit=>100
       t.column :reserved1, :string, :limit=>100
       t.column :reserved2, :string, :limit=>100
       t.column :reserved3, :string, :limit=>100
    end
    admin = YtaplUser.new
    admin.id = 1
    admin.name = 'admin'
    admin.truename = '系统管理员'
    admin.datecreated = Time.new
    admin.password = '5f4dcc3b5aa765d61d8327deb882cf99'
    admin.roleid = 1
    admin.save
  end

  def self.down
    drop_table :ytapl_users
  end
end
