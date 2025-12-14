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

ActiveRecord::Schema.define(version: 20251214093357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.string "pet_type"
    t.string "breed"
    t.integer "age"
    t.string "location"
    t.text "description"
    t.string "status"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "size"
    t.string "sex"
    t.string "health_status"
    t.boolean "vaccinated", default: false
    t.float "lat"
    t.float "lon"
    t.boolean "available", default: true
    t.string "city"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.string "image"
    t.string "energy_level"
    t.boolean "apartment_friendly", default: false
    t.boolean "kids_friendly", default: false
    t.boolean "affectionate", default: false
    t.string "temperament"
    t.boolean "social_with_other_pets", default: false
    t.boolean "social_with_children", default: false
    t.string "trainability"
    t.string "grooming_needs"
    t.string "exercise_needs"
    t.index ["available"], name: "index_pets_on_available"
    t.index ["breed"], name: "index_pets_on_breed"
    t.index ["pet_type"], name: "index_pets_on_pet_type"
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.string "status"
    t.bigint "pet_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "request_type"
    t.text "notes"
    t.string "route"
    t.float "route_distance"
    t.datetime "scheduled_date"
    t.datetime "completed_at"
    t.text "rejection_reason"
    t.index ["pet_id"], name: "index_requests_on_pet_id"
    t.index ["request_type"], name: "index_requests_on_request_type"
    t.index ["status"], name: "index_requests_on_status"
    t.index ["user_id", "created_at"], name: "index_requests_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "role"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "preferred_species"
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.text "bio"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "pets", "users"
  add_foreign_key "requests", "pets"
  add_foreign_key "requests", "users"
end
