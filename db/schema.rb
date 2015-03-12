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

ActiveRecord::Schema.define(version: 20150311213656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "diagnoses", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "disease_id"
    t.integer  "log_id"
    t.integer  "symptom_id"
    t.integer  "factor_id"
    t.decimal  "symptom_score"
    t.decimal  "factor_score"
    t.boolean  "in_progress"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "disease_factors", force: :cascade do |t|
    t.integer "disease_id"
    t.integer "factor_id"
  end

  create_table "disease_symptoms", force: :cascade do |t|
    t.integer "disease_id"
    t.integer "symptom_id"
  end

  create_table "diseases", force: :cascade do |t|
    t.string  "name"
    t.integer "parent_id"
  end

  create_table "factors", force: :cascade do |t|
    t.string  "name"
    t.integer "parent_id"
  end

  create_table "logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "request"
    t.string   "response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "symptoms", force: :cascade do |t|
    t.string  "name"
    t.string  "question"
    t.decimal "severity"
    t.integer "parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string  "phone"
    t.integer "age"
  end

end
