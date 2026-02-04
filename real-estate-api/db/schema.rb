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

ActiveRecord::Schema[8.1].define(version: 2026_02_03_172650) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audiences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.jsonb "filters", default: {}, null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_audiences_on_created_by_id"
    t.index ["deleted_at"], name: "index_audiences_on_deleted_at"
    t.index ["filters"], name: "index_audiences_on_filters", opclass: :jsonb_path_ops, using: :gin
    t.index ["organization_id", "deleted_at"], name: "index_audiences_on_org_and_deleted"
    t.index ["organization_id", "name"], name: "index_audiences_on_org_and_name", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_audiences_on_organization_id"
  end

  create_table "campaign_audiences", force: :cascade do |t|
    t.bigint "audience_id", null: false
    t.bigint "campaign_id", null: false
    t.datetime "created_at", null: false
    t.index ["audience_id"], name: "index_campaign_audiences_on_audience_id"
    t.index ["campaign_id", "audience_id"], name: "index_campaign_audiences_on_campaign_and_audience", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.datetime "scheduled_at"
    t.integer "scheduled_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_campaigns_on_created_by_id"
    t.index ["deleted_at"], name: "index_campaigns_on_deleted_at"
    t.index ["organization_id", "deleted_at"], name: "index_campaigns_on_org_and_deleted"
    t.index ["organization_id", "name"], name: "index_campaigns_on_org_and_name", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id", "status", "deleted_at"], name: "index_campaigns_on_org_status_deleted"
    t.index ["organization_id"], name: "index_campaigns_on_organization_id"
    t.index ["scheduled_at", "status"], name: "index_campaigns_on_scheduled_pending", where: "((deleted_at IS NULL) AND (scheduled_at IS NOT NULL))"
    t.index ["scheduled_at"], name: "index_campaigns_on_scheduled_at"
    t.index ["status"], name: "index_campaigns_on_status"
    t.check_constraint "scheduled_at IS NULL OR scheduled_at >= created_at", name: "scheduled_at_on_or_after_created"
    t.check_constraint "scheduled_type >= 0", name: "valid_scheduled_type"
    t.check_constraint "status >= 0", name: "valid_campaign_status"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "organization_id", null: false
    t.string "phone"
    t.jsonb "preferences", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["deleted_at"], name: "index_contacts_on_deleted_at"
    t.index ["organization_id", "deleted_at"], name: "index_contacts_on_org_and_deleted"
    t.index ["organization_id", "email"], name: "index_contacts_on_organization_id_and_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_contacts_on_organization_id"
    t.index ["phone"], name: "index_contacts_on_phone", unique: true, where: "((deleted_at IS NULL) AND (phone IS NOT NULL))"
    t.index ["preferences"], name: "index_contacts_on_preferences", opclass: :jsonb_path_ops, using: :gin
    t.check_constraint "email::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$'::text", name: "valid_email_format"
    t.check_constraint "phone IS NULL OR phone::text ~ '^(\\+91|91)?[6-9][0-9]{9}$'::text", name: "valid_india_mobile_phone"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["name"], name: "index_organizations_on_name", unique: true, where: "(deleted_at IS NULL)"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.datetime "deleted_at"
    t.string "email", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.string "invitation_token"
    t.bigint "invited_by_id"
    t.string "jti", null: false
    t.bigint "organization_id"
    t.string "password_digest"
    t.integer "role", default: 2, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["invitation_token", "invitation_accepted_at"], name: "index_users_on_pending_invitations", where: "((invitation_accepted_at IS NULL) AND (invitation_token IS NOT NULL))"
    t.index ["invitation_token"], name: "index_users_on_invitation_token"
    t.index ["invitation_token"], name: "index_users_on_unique_invitation_token", unique: true, where: "(invitation_token IS NOT NULL)"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["organization_id", "deleted_at"], name: "index_users_on_org_and_deleted"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["status", "deleted_at"], name: "index_users_on_status_and_deleted"
    t.check_constraint "email::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$'::text", name: "valid_user_email_format"
    t.check_constraint "role >= 0 AND role <= 2", name: "valid_role_range"
    t.check_constraint "status >= 0", name: "valid_user_status"
  end

  add_foreign_key "audiences", "organizations", on_delete: :cascade
  add_foreign_key "audiences", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "campaign_audiences", "audiences", on_delete: :cascade
  add_foreign_key "campaign_audiences", "campaigns", on_delete: :cascade
  add_foreign_key "campaigns", "organizations", on_delete: :cascade
  add_foreign_key "campaigns", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "contacts", "organizations", on_delete: :cascade
  add_foreign_key "contacts", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "users", "organizations", on_delete: :nullify
  add_foreign_key "users", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "users", "users", column: "invited_by_id", on_delete: :nullify
end
