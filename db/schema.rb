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

ActiveRecord::Schema[8.0].define(version: 2025_04_09_034141) do
  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.string "email"
    t.string "phone"
    t.text "notes"
    t.string "status"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "devis", force: :cascade do |t|
    t.string "titre"
    t.text "description"
    t.string "statut"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "client_id"
    t.index ["client_id"], name: "index_devis_on_client_id"
    t.index ["user_id"], name: "index_devis_on_user_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.string "name", null: false
    t.string "category"
    t.string "subject", null: false
    t.text "content", null: false
    t.json "variables", default: {}
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_email_templates_on_name"
    t.index ["user_id", "category"], name: "index_email_templates_on_user_id_and_category"
    t.index ["user_id"], name: "index_email_templates_on_user_id"
  end

  create_table "offer_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "content", null: false
    t.string "category", null: false
    t.string "location"
    t.integer "capacity_min"
    t.integer "capacity_max"
    t.decimal "base_price", precision: 10, scale: 2
    t.json "metadata"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location"], name: "index_offer_templates_on_location"
    t.index ["user_id", "category"], name: "index_offer_templates_on_user_id_and_category"
    t.index ["user_id"], name: "index_offer_templates_on_user_id"
  end

  create_table "offers", force: :cascade do |t|
    t.integer "devis_id", null: false
    t.text "content"
    t.text "original_content"
    t.boolean "edited"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["devis_id"], name: "index_offers_on_devis_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "clients", "users"
  add_foreign_key "devis", "clients"
  add_foreign_key "devis", "users"
  add_foreign_key "email_templates", "users"
  add_foreign_key "offer_templates", "users"
  add_foreign_key "offers", "devis"
end
