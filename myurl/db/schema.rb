# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 16) do

  create_table "catalogs", :force => true do |t|
    t.column "user_id",   :integer
    t.column "name",      :string,  :limit => 50
    t.column "parent_id", :integer
  end

  create_table "hots", :force => true do |t|
    t.column "user_id", :integer
    t.column "address", :string,  :limit => 200
    t.column "name",    :string,  :limit => 200
  end

  create_table "jokes", :force => true do |t|
    t.column "title", :string, :limit => 250
    t.column "text",  :text
  end

  create_table "labels", :force => true do |t|
    t.column "name",  :string,  :limit => 50
    t.column "order", :integer
  end

  create_table "messages", :force => true do |t|
    t.column "name", :string, :limit => 200
    t.column "text", :string, :limit => 200
  end

  create_table "recents", :force => true do |t|
    t.column "user_id",    :integer
    t.column "site_id",    :integer
    t.column "created_at", :datetime
    t.column "kind",       :integer
    t.column "desc",       :string,   :limit => 250
  end

  create_table "recommand_tag", :id => false, :force => true do |t|
    t.column "recommand_id", :integer
    t.column "tag_id",       :integer
  end

  create_table "recommands", :force => true do |t|
    t.column "address",     :string,   :limit => 250
    t.column "name",        :string,   :limit => 200
    t.column "logo",        :string,   :limit => 250
    t.column "label_id",    :integer
    t.column "adopt_count", :integer
    t.column "user_id",     :integer
    t.column "created_at",  :datetime
  end

  create_table "remarks", :force => true do |t|
    t.column "user_id", :integer
    t.column "url_id",  :integer
    t.column "desc",    :string,  :limit => 200
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "simple_captcha_data", :force => true do |t|
    t.column "key",        :string,   :limit => 40
    t.column "value",      :string,   :limit => 6
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "sites", :force => true do |t|
    t.column "label_id", :integer
    t.column "address",  :string,  :limit => 200
    t.column "name",     :string,  :limit => 200
    t.column "desc",     :string,  :limit => 200
    t.column "green",    :integer
    t.column "ticks",    :integer
  end

  create_table "tags", :force => true do |t|
    t.column "name", :string, :limit => 50
  end

  create_table "user_url", :id => false, :force => true do |t|
    t.column "user_id", :integer
    t.column "url_id",  :integer
  end

  create_table "users", :force => true do |t|
    t.column "name",        :string,  :limit => 100
    t.column "nickname",    :string,  :limit => 100
    t.column "password",    :string,  :limit => 100
    t.column "adopt_count", :integer
    t.column "ext1",        :string,  :limit => 100
    t.column "ext2",        :string,  :limit => 100
    t.column "ext3",        :string,  :limit => 100
    t.column "ext4",        :integer
    t.column "ext5",        :integer
    t.column "ext6",        :integer
  end

  create_table "weburls", :force => true do |t|
    t.column "address",      :string,   :limit => 250
    t.column "desc",         :string,   :limit => 250
    t.column "logo",         :string,   :limit => 250
    t.column "catalog_id",   :integer
    t.column "adpot_count",  :integer
    t.column "created_at",   :datetime
    t.column "recommand_id", :integer
    t.column "user_id",      :integer
    t.column "ext2",         :string,   :limit => 100
    t.column "ext3",         :string,   :limit => 100
    t.column "ext4",         :integer
    t.column "ext5",         :integer
    t.column "ext6",         :integer
  end

end
