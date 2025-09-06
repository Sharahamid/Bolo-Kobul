# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_05_20_233846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abouts", force: :cascade do |t|
    t.text "content"
    t.string "content_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "display_order", default: 0
  end

  create_table "academic_informations", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "result"
    t.datetime "start_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "end_date"
    t.string "passing_year"
    t.string "institution"
    t.string "degree"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_admin_managed_resources", force: :cascade do |t|
    t.string "class_name", null: false
    t.string "action", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["class_name", "action", "name"], name: "active_admin_managed_resources_index", unique: true
  end

  create_table "active_admin_permissions", force: :cascade do |t|
    t.integer "managed_resource_id", null: false
    t.integer "role", limit: 2, default: 0, null: false
    t.integer "state", limit: 2, default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["managed_resource_id", "role"], name: "active_admin_permissions_index", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "ad_locations", force: :cascade do |t|
    t.integer "location"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", limit: 2, default: 0, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ads", force: :cascade do |t|
    t.integer "advertiser_profile_id"
    t.integer "location", default: 0
    t.string "title"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.integer "price", default: 0
    t.string "advertiser"
  end

  create_table "advertiser_profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "email"
    t.string "company_name"
    t.integer "total_earning"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "appearances", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.decimal "weight"
    t.integer "body_type"
    t.integer "complexion"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "body_art"
    t.integer "is_hijab"
    t.integer "is_niqab"
    t.string "hair_color"
    t.string "hair_type"
    t.string "eye_color"
    t.string "hair_length"
    t.integer "eye_wear"
    t.integer "physical_status"
  end

  create_table "assisted_services", force: :cascade do |t|
    t.string "page_title"
    t.text "page_content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "display_order", default: 0
    t.string "name", null: false
    t.decimal "price", default: "0.0"
  end

  create_table "blogs", force: :cascade do |t|
    t.string "title"
    t.string "email"
    t.integer "status", default: 0
    t.string "author"
    t.string "partner"
    t.datetime "started_at"
    t.text "story"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.integer "story_type", default: 0
    t.string "married_life_duration"
    t.index ["slug"], name: "index_blogs_on_slug", unique: true
  end

  create_table "butterfly_configs", force: :cascade do |t|
    t.integer "profile_view_butterflies", default: 0
    t.integer "chat_butterflies", default: 0
    t.float "butterfly_price", default: 0.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "num_of_free_butterfly", default: 0
    t.integer "text_alert_butterflies", default: 0
    t.boolean "butterfly_animation", default: false
    t.integer "adv_search_butterflies", default: 0
    t.integer "max_marriage_profiles", default: 5
  end

  create_table "chat_friendships", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "chat_friend_id"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "chat_room_users", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "chat_room_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.integer "chat_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_private", default: false
  end

  create_table "contacts", force: :cascade do |t|
    t.text "content"
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "heading"
    t.string "contact"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cultural_values", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "birth_place"
    t.integer "mother_tongue"
    t.text "languages_spoken"
    t.integer "religion"
    t.integer "resident_type"
    t.text "political_view"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "attend_religious_event"
    t.integer "willing_to_relocate"
    t.string "nationality"
    t.integer "born_or_reverted"
  end

  create_table "customer_support_replies", force: :cascade do |t|
    t.bigint "customer_support_id", null: false
    t.string "repliable_type"
    t.integer "repliable_id"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_support_id"], name: "index_customer_support_replies_on_customer_support_id"
  end

  create_table "customer_supports", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.string "issue_type"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
  end

  create_table "designations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.integer "division_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "divisions", force: :cascade do |t|
    t.integer "country_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "family_members", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "relation"
    t.string "name"
    t.integer "residence_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "marital_status"
    t.integer "occupation"
    t.string "permanent_address"
  end

  create_table "faqs", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "display_order", default: 0
  end

  create_table "favourites", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "favourite_profile_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "friendships", id: :serial, force: :cascade do |t|
    t.string "friendable_type"
    t.integer "friendable_id"
    t.integer "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "blocker_id"
    t.integer "status"
    t.integer "chat_request_sender_id"
    t.index ["friendable_id", "friend_id"], name: "index_friendships_on_friendable_id_and_friend_id", unique: true
  end

  create_table "hobbies_and_interests", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.text "hobby"
    t.text "interest"
    t.text "favourite_movie"
    t.text "favourite_tv_show"
    t.text "favourite_sports_show"
    t.text "fitness_activity"
    t.text "cuisine"
    t.text "travel"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "music_type"
    t.text "reading_type"
    t.string "specific_entertainment"
    t.text "music"
    t.text "read"
    t.string "favourite_book"
    t.string "favourite_song"
  end

  create_table "issue_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "life_styles", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "food_habits"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "dress_style"
    t.string "living_with"
    t.integer "drinker"
    t.integer "smoker"
    t.text "specific_habits"
  end

  create_table "market_place_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "market_places", force: :cascade do |t|
    t.string "name"
    t.decimal "cost"
    t.integer "status", default: 0
    t.string "costing_unit"
    t.text "facility"
    t.text "policy"
    t.text "experience"
    t.text "about"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "service_coverage"
    t.string "location"
    t.integer "market_place_type_id"
    t.string "link"
  end

  create_table "marriage_informations", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "no_of_childrens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "have_children"
    t.boolean "want_more_child"
  end

  create_table "marriage_profiles", force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.string "name"
    t.integer "gender"
    t.integer "marital_status"
    t.integer "highest_education_level"
    t.integer "family_values"
    t.integer "family_type"
    t.integer "family_status"
    t.integer "blood_group"
    t.integer "relation"
    t.integer "profile_completeness", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "nid_or_passport"
    t.integer "height_inch"
    t.text "about_my_self"
    t.string "slug"
    t.datetime "date_of_birth"
    t.integer "religion"
    t.integer "height_ft"
    t.text "description"
    t.text "special_circumstances"
    t.text "hometown"
    t.text "present_location"
    t.boolean "verified"
    t.string "profile_image"
    t.string "identification_document"
    t.string "photo_1"
    t.string "photo_2"
    t.string "photo_3"
    t.text "present_address"
    t.index ["slug"], name: "index_marriage_profiles_on_slug", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.integer "chat_room_id"
    t.text "body"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.boolean "is_read", default: false
    t.integer "recipient_id"
    t.integer "sender_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "content"
    t.integer "category", default: 0
    t.boolean "will_email", default: true
    t.boolean "will_sms", default: true
  end

  create_table "occupations", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "organization"
    t.integer "employment_status"
    t.datetime "start_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "working_currently"
    t.datetime "end_date"
    t.integer "name"
    t.string "designation"
    t.integer "monthly_income"
    t.string "company_name"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id"
    t.integer "quantity"
    t.integer "payment_method"
    t.integer "status"
    t.decimal "price"
    t.decimal "sub_total_amount"
    t.string "promo_code"
    t.decimal "discount_amount"
    t.decimal "total_amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "txn_no"
    t.integer "product", default: 0
    t.string "customer_name"
    t.string "customer_phone"
    t.string "customer_email"
    t.bigint "assisted_service_id"
    t.index ["assisted_service_id"], name: "index_orders_on_assisted_service_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partner_preferences", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "gender"
    t.integer "max_age"
    t.integer "min_age"
    t.integer "marital_status"
    t.integer "highest_education_level"
    t.integer "family_values"
    t.integer "family_type"
    t.integer "family_status"
    t.text "blood_group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "religion"
    t.integer "physical_status"
    t.integer "min_height"
    t.integer "max_height"
    t.text "hometown"
    t.text "present_location"
    t.integer "max_inch"
    t.integer "min_inch"
  end

  create_table "partner_requests", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.integer "blocker_id"
    t.integer "request_type"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "permanent_addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.integer "addressable_id"
    t.integer "division"
    t.integer "district"
    t.integer "thana"
    t.integer "union"
    t.string "address_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "precautionary_measures", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "display_order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "present_addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.integer "addressable_id"
    t.integer "division"
    t.integer "district"
    t.integer "thana"
    t.integer "union"
    t.string "address_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "privacy_policies", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "display_order", default: 0
  end

  create_table "privacy_settings", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "gender", default: 0
    t.integer "date_of_birth", default: 1
    t.integer "highest_education_level", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "height_ft", default: 1
    t.integer "physical_status", default: 1
    t.integer "family_values", default: 1
    t.integer "family_type", default: 1
    t.integer "family_status", default: 1
    t.integer "current_occupation", default: 1
  end

  create_table "process_flows", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "display_order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "success_stories", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "facebook_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "suggested_profiles", force: :cascade do |t|
    t.integer "marriage_profile_id"
    t.integer "matching_percent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "terms_of_uses", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "display_order", default: 0
  end

  create_table "thanas", force: :cascade do |t|
    t.string "name"
    t.integer "district_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "order_id"
    t.integer "status"
    t.decimal "amount"
    t.decimal "currency_amount"
    t.decimal "discount_amount"
    t.decimal "discount_percentage"
    t.string "card_type"
    t.string "card_no"
    t.string "currency"
    t.string "bank_tran_id"
    t.string "card_issuer"
    t.string "transaction_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "unions", force: :cascade do |t|
    t.string "name"
    t.integer "thana_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "country_code", default: "", null: false
    t.string "phone_number", default: "", null: false
    t.string "national_id", default: "", null: false
    t.boolean "verified", default: false, null: false
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.string "slug"
    t.string "username"
    t.integer "authy_id"
    t.integer "created_for"
    t.integer "butterfly_number"
    t.integer "block_butterfly_number"
    t.boolean "deactivated", default: false
    t.integer "text_alert", default: 0
    t.string "refferel_code"
    t.string "refferel_promo_code"
    t.integer "advanced_search", default: 0
    t.boolean "is_reference", default: false
    t.string "identification_document"
    t.string "otp"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customer_support_replies", "customer_supports"
end
