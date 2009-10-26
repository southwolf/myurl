# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091023084100) do

  create_table "archievements", :force => true do |t|
    t.integer  "user_id"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end


  create_table "kaixintasks", :force => true do |t|
    t.integer  "tasktype"
    t.integer  "kaixinscheduler_id"
    t.integer  "kaixinuser_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kaixinusers", :force => true do |t|
    t.string   "name",       :limit => 40
    t.string   "password",   :limit => 40
    t.text     "friends"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name",          :limit => 40
    t.string   "password",      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kaixinuser_id"
  end

end
