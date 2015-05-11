# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150511010116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "credentials", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "encrypted_twitter_oauth_token_secret"
    t.string   "encrypted_twitter_oauth_token"
  end

  create_table "twitter_follow_preferences", force: :cascade do |t|
    t.integer  "unfollow_after",   default: 1
    t.text     "hashtags",         default: ""
    t.integer  "user_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.datetime "rate_limit_until", default: '2015-05-01 04:41:07'
    t.boolean  "mass_follow",      default: true
    t.boolean  "mass_unfollow",    default: true
  end

  create_table "twitter_follows", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "unfollowed",      default: false
    t.string   "username"
    t.datetime "followed_at"
    t.datetime "unfollowed_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "hashtag"
    t.string   "twitter_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "twitter_uid"
    t.string   "name"
    t.string   "twitter_username"
  end

end
