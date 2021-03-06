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

ActiveRecord::Schema.define(version: 20180430191220) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.integer "pageid"
    t.string "title"
    t.string "categories"
    t.string "links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "integritous"
  end

  create_table "categories", force: :cascade do |t|
    t.string "title"
    t.string "articles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reference_instances", force: :cascade do |t|
    t.string "revid"
    t.string "reftype"
    t.string "wikitext"
    t.integer "size"
    t.integer "position"
    t.string "refname"
    t.string "content"
    t.string "comments"
    t.string "factoid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "revisions", force: :cascade do |t|
    t.integer "revid"
    t.integer "pageid"
    t.integer "parentid"
    t.string "user"
    t.integer "userid"
    t.integer "size"
    t.datetime "timestamp"
    t.string "comment"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "parsetree"
    t.string "wikitext"
    t.boolean "scraped"
  end

end
