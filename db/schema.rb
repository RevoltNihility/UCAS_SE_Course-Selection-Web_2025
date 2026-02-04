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

ActiveRecord::Schema[8.1].define(version: 2026_02_04_111113) do
  create_table "courses", force: :cascade do |t|
    t.integer "class_hours"
    t.string "code", null: false
    t.integer "course_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "credits", null: false
    t.integer "max_enrollment", default: 100, null: false
    t.string "name", null: false
    t.string "schedule_time"
    t.string "teacher"
    t.datetime "updated_at", null: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.string "academic_year"
    t.integer "course_id", null: false
    t.integer "course_type"
    t.datetime "created_at", null: false
    t.integer "grade"
    t.integer "semester"
    t.integer "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", limit: 20, null: false
    t.string "student_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["email", "student_id"], name: "index_students_on_email_and_student_id", unique: true
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "students"
  add_foreign_key "students", "users"
end
