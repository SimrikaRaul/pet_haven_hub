# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_20_144841) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "pets", force: :cascade do |t|
    t.boolean "affectionate", default: false
    t.integer "age"
    t.boolean "apartment_friendly", default: false
    t.boolean "available", default: true
    t.string "breed"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "energy_level"
    t.string "exercise_needs"
    t.string "grooming_needs"
    t.string "health_status"
    t.string "image"
    t.boolean "kids_friendly", default: false
    t.float "lat"
    t.float "latitude"
    t.string "location"
    t.float "lon"
    t.float "longitude"
    t.string "name"
    t.string "pet_type"
    t.string "sex"
    t.string "size"
    t.boolean "social_with_children", default: false
    t.boolean "social_with_other_pets", default: false
    t.string "status"
    t.string "temperament"
    t.string "trainability"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "vaccinated", default: false
    t.index ["available"], name: "index_pets_on_available"
    t.index ["breed"], name: "index_pets_on_breed"
    t.index ["pet_type"], name: "index_pets_on_pet_type"
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "pet_id"
    t.text "rejection_reason"
    t.string "request_type"
    t.string "route"
    t.float "route_distance"
    t.datetime "scheduled_date"
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["pet_id"], name: "index_requests_on_pet_id"
    t.index ["request_type"], name: "index_requests_on_request_type"
    t.index ["status"], name: "index_requests_on_status"
    t.index ["user_id", "created_at"], name: "index_requests_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "user_preferences", force: :cascade do |t|
    t.boolean "apartment_friendly_required", default: false
    t.datetime "created_at", null: false
    t.boolean "has_other_pets", default: false
    t.boolean "kids_in_home", default: false
    t.string "preferred_energy_level"
    t.string "preferred_exercise_needs"
    t.string "preferred_grooming_needs"
    t.string "preferred_temperament"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "wants_affectionate_pet", default: false
    t.index ["user_id"], name: "index_user_preferences_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.text "bio"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.string "preferred_species"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "pets", "users"
  add_foreign_key "requests", "pets"
  add_foreign_key "requests", "users"
  add_foreign_key "user_preferences", "users"
end
