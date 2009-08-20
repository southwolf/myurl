class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string, :limit=>100
      t.column :nickname, :string, :limit=>100
      t.column :password, :string, :limit=>100
      t.column :adopt_count, :integer
      t.column :ext1, :string, :limit=>100
      t.column :ext2, :string, :limit=>100
      t.column :ext3, :string, :limit=>100
      t.column :ext4, :integer
      t.column :ext5, :integer
      t.column :ext6, :integer
    end
    
    user = User.new
    user.name = "admin"
    user.password = (Digest::MD5.new << "198011272010").hexdigest
    user.save
  end

  def self.down
    drop_table :users
  end
end
