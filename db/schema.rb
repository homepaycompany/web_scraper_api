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

ActiveRecord::Schema.define(version: 20180509155146) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "city"
    t.integer "min_price", default: 0
    t.integer "max_price", default: 999999999
    t.integer "min_size_sqm", default: 0
    t.integer "max_size_sqm", default: 999999999
    t.float "min_price_per_sqm", default: 0.0
    t.float "max_price_per_sqm", default: 999999999.0
    t.string "name"
    t.date "last_sent_date"
    t.integer "min_number_of_rooms", default: 0
    t.integer "max_number_of_rooms", default: 999999999
    t.integer "zipcode"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "price"
    t.date "updated_on"
    t.date "removed_on"
    t.string "address"
    t.string "property_type"
    t.integer "num_floors"
    t.integer "num_rooms"
    t.integer "num_bedrooms"
    t.integer "num_bathrooms"
    t.integer "property_total_size_sqm"
    t.integer "building_construction_year"
    t.boolean "has_balcony"
    t.boolean "has_garage"
    t.boolean "has_terrace"
    t.boolean "has_cellar"
    t.boolean "has_parking"
    t.boolean "has_elevator"
    t.boolean "has_works_in_building_planned"
    t.string "building_state"
    t.string "property_state"
    t.boolean "has_pool"
    t.boolean "has_attic"
    t.boolean "is_attic_convertible"
    t.integer "appartment_floor"
    t.integer "livable_size_sqm"
    t.integer "ground_floor_size_sqm"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.string "email"
    t.string "all_prices"
    t.string "all_updates"
    t.string "urls"
    t.string "status"
    t.date "posted_on"
    t.float "latitude"
    t.float "longitude"
    t.string "search_location"
    t.string "city"
    t.string "location_type"
    t.string "user_type"
    t.boolean "need_to_enrich_location", default: true
    t.boolean "need_to_enrich_attributes", default: true
    t.float "size_balcony_sqm"
    t.float "size_terrace_sqm"
    t.float "size_cellar_sqm"
    t.boolean "sold_rented"
    t.float "agent_commission"
    t.date "attributes_enriched_at"
    t.date "location_enriched_at"
    t.float "price_per_sqm"
    t.boolean "lifetime_annuity", default: false
    t.boolean "need_to_check_for_duplicates", default: true
    t.boolean "is_residence", default: false
    t.integer "zipcode"
  end

  create_table "property_alerts", force: :cascade do |t|
    t.bigint "property_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "to_send"
    t.integer "user_id"
    t.index ["alert_id"], name: "index_property_alerts_on_alert_id"
    t.index ["property_id"], name: "index_property_alerts_on_property_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "alerts", "users"
  add_foreign_key "property_alerts", "alerts"
  add_foreign_key "property_alerts", "properties"
end
