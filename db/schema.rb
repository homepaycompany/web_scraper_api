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

ActiveRecord::Schema.define(version: 20180319164804) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "price"
    t.date "posted_on"
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
  end

end
