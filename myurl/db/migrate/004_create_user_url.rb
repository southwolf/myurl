# Copyright (c) 2008 [Sur http://expressica.com]

class CreateUserUrl < ActiveRecord::Migration
  def self.up
    create_table :user_url, :id=>false do |t|
      t.column :user_id, :integer
      t.column :url_id, :integer
    end
  end

  def self.down
    drop_table :user_url
  end
end
