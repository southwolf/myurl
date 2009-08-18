# Copyright (c) 2008 [Sur http://expressica.com]

class CreateRemarks < ActiveRecord::Migration
  def self.up
    create_table :remarks do |t|
      t.column :user_id, :integer
      t.column :url_id, :integer
      t.column :desc, :string, :limit=>200
    end
  end

  def self.down
    drop_table :remarks
  end
end
