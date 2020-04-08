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

ActiveRecord::Schema.define(version: 2020_03_10_114812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auths", force: :cascade do |t|
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
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "logistician_id"
    t.bigint "master_admin_id"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.index ["confirmation_token"], name: "index_auths_on_confirmation_token", unique: true
    t.index ["email"], name: "index_auths_on_email", unique: true
    t.index ["logistician_id"], name: "index_auths_on_logistician_id"
    t.index ["master_admin_id"], name: "index_auths_on_master_admin_id"
    t.index ["reset_password_token"], name: "index_auths_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_auths_on_uid_and_provider", unique: true
    t.index ["unlock_token"], name: "index_auths_on_unlock_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "nip"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.string "postal_code"
    t.string "street"
    t.datetime "archived_at"
    t.integer "tz"
  end

  create_table "device_media_files", force: :cascade do |t|
    t.bigint "trailer_id"
    t.bigint "trailer_event_id"
    t.bigint "logistician_id"
    t.string "url"
    t.datetime "requested_at"
    t.datetime "taken_at"
    t.integer "kind"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "requested_time"
    t.integer "camera"
    t.string "file"
    t.string "uuid"
    t.index ["logistician_id"], name: "index_device_media_files_on_logistician_id"
    t.index ["trailer_event_id"], name: "index_device_media_files_on_trailer_event_id"
    t.index ["trailer_id"], name: "index_device_media_files_on_trailer_id"
    t.index ["url"], name: "index_device_media_files_on_url"
    t.index ["uuid"], name: "index_device_media_files_on_uuid"
  end

  create_table "drivers", force: :cascade do |t|
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_notifications", force: :cascade do |t|
    t.string "lang"
    t.string "receiver_email"
    t.integer "email_priority"
    t.string "user_name"
    t.string "user_company"
    t.string "subject"
    t.text "body"
    t.datetime "event_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logisticians", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.integer "preferred_locale", default: 0, null: false
  end

  create_table "master_admins", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
  end

  create_table "people", force: :cascade do |t|
    t.string "personifiable_type"
    t.bigint "personifiable_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "extra_phone_number"
    t.string "email"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.index ["company_id"], name: "index_people_on_company_id"
    t.index ["personifiable_type", "personifiable_id"], name: "index_people_on_personifiable_type_and_personifiable_id"
  end

  create_table "plans", force: :cascade do |t|
    t.integer "kind", default: 0
    t.integer "features", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "trailer_id"
    t.index ["trailer_id"], name: "index_plans_on_trailer_id"
  end

  create_table "route_logs", force: :cascade do |t|
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "trailer_id"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location_name"
    t.string "locale"
    t.bigint "trailer_event_id"
    t.bigint "trailer_media_file_id"
    t.float "timestamp"
    t.decimal "speed"
    t.index ["sent_at"], name: "index_route_logs_on_sent_at", order: :desc
    t.index ["trailer_event_id"], name: "index_route_logs_on_trailer_event_id"
    t.index ["trailer_id"], name: "index_route_logs_on_trailer_id"
    t.index ["trailer_media_file_id"], name: "index_route_logs_on_trailer_media_file_id"
  end

  create_table "trailer_access_permissions", force: :cascade do |t|
    t.boolean "sensor_access", default: false
    t.boolean "event_log_access", default: false
    t.bigint "logistician_id"
    t.bigint "trailer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "alarm_control", default: false
    t.boolean "system_arm_control", default: false
    t.boolean "load_in_mode_control", default: false
    t.boolean "photo_download", default: false
    t.boolean "video_download", default: false
    t.boolean "monitoring_access", default: false
    t.boolean "current_position", default: false
    t.boolean "route_access", default: false
    t.boolean "alarm_resolve_control"
    t.index ["logistician_id"], name: "index_trailer_access_permissions_on_logistician_id"
    t.index ["trailer_id"], name: "index_trailer_access_permissions_on_trailer_id"
  end

  create_table "trailer_cameras", force: :cascade do |t|
    t.bigint "trailer_id"
    t.integer "camera_type"
    t.datetime "installed_at"
    t.datetime "updated_at"
    t.index ["trailer_id"], name: "index_trailer_cameras_on_trailer_id"
  end

  create_table "trailer_data_usage_syncs", force: :cascade do |t|
    t.datetime "last_sync_at"
    t.integer "updated_trailers"
  end

  create_table "trailer_events", force: :cascade do |t|
    t.integer "kind"
    t.string "sensor_name"
    t.datetime "triggered_at"
    t.string "uuid"
    t.bigint "trailer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "linked_event_id"
    t.bigint "logistician_id"
    t.bigint "trailer_sensor_reading_id"
    t.index ["linked_event_id"], name: "index_trailer_events_on_linked_event_id"
    t.index ["logistician_id"], name: "index_trailer_events_on_logistician_id"
    t.index ["trailer_id"], name: "index_trailer_events_on_trailer_id"
    t.index ["trailer_sensor_reading_id"], name: "index_trailer_events_on_trailer_sensor_reading_id"
    t.index ["uuid"], name: "index_trailer_events_on_uuid"
  end

  create_table "trailer_sensor_readings", force: :cascade do |t|
    t.bigint "trailer_sensor_id"
    t.float "original_value"
    t.float "maximum_value"
    t.float "value"
    t.integer "value_percentage"
    t.integer "status"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_trailer_sensor_readings_on_read_at"
    t.index ["trailer_sensor_id", "read_at"], name: "index_trailer_sensor_readings_on_trailer_sensor_id_and_read_at"
    t.index ["trailer_sensor_id"], name: "index_trailer_sensor_readings_on_trailer_sensor_id"
  end

  create_table "trailer_sensor_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "alarm_primary_value"
    t.float "alarm_secondary_value"
    t.float "warning_primary_value"
    t.float "warning_secondary_value"
    t.boolean "send_sms"
    t.boolean "send_email"
    t.text "phone_numbers", default: [], array: true
    t.text "email_addresses", default: [], array: true
    t.bigint "trailer_sensor_id"
    t.index ["trailer_sensor_id"], name: "index_trailer_sensor_settings_on_trailer_sensor_id"
  end

  create_table "trailer_sensors", force: :cascade do |t|
    t.bigint "trailer_id"
    t.float "value"
    t.integer "value_percentage"
    t.integer "status"
    t.integer "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trailer_id"], name: "index_trailer_sensors_on_trailer_id"
  end

  create_table "trailers", force: :cascade do |t|
    t.string "device_serial_number"
    t.string "registration_number"
    t.integer "make"
    t.string "model"
    t.text "description"
    t.datetime "device_installed_at"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banana_pi_token"
    t.string "channel_uuid"
    t.datetime "archived_at"
    t.string "spedition_company"
    t.string "transport_company"
    t.integer "status"
    t.boolean "engine_running", default: false
    t.boolean "network_available", default: false
    t.string "phone_number"
    t.jsonb "data_usage", default: {}
    t.datetime "subscribed_at"
    t.jsonb "recording_list", default: {}
    t.index ["company_id"], name: "index_trailers_on_company_id"
  end

  create_table "warning_notifications", force: :cascade do |t|
    t.datetime "sent_at"
    t.integer "kind"
    t.string "contact_information"
    t.bigint "trailer_sensor_reading_id"
    t.index ["trailer_sensor_reading_id"], name: "index_warning_notifications_on_trailer_sensor_reading_id"
  end

  add_foreign_key "device_media_files", "trailer_events"
  add_foreign_key "device_media_files", "trailers"
  add_foreign_key "people", "companies"
  add_foreign_key "plans", "trailers"
  add_foreign_key "trailer_access_permissions", "logisticians"
  add_foreign_key "trailer_access_permissions", "trailers"
  add_foreign_key "trailer_cameras", "trailers"
  add_foreign_key "trailer_events", "logisticians"
  add_foreign_key "trailer_events", "trailer_events", column: "linked_event_id"
  add_foreign_key "trailer_sensor_readings", "trailer_sensors"
  add_foreign_key "trailer_sensor_settings", "trailer_sensors"
  add_foreign_key "trailer_sensors", "trailers"
  add_foreign_key "trailers", "companies"
  add_foreign_key "warning_notifications", "trailer_sensor_readings"
end
