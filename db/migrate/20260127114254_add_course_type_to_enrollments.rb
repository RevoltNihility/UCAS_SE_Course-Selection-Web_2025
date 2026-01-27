class AddCourseTypeToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :course_type, :integer
  end
end
