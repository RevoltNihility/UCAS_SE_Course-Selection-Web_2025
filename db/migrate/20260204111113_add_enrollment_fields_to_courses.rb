class AddEnrollmentFieldsToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :max_enrollment, :integer, default: 100, null: false
    add_column :courses, :course_type, :integer, default: 0, null: false
    add_column :courses, :schedule_time, :string
  end
end
