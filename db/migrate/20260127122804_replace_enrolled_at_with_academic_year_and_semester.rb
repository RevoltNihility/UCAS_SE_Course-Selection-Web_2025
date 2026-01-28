class ReplaceEnrolledAtWithAcademicYearAndSemester < ActiveRecord::Migration[8.1]
  def change
    remove_column :enrollments, :enrolled_at, :datetime
    add_column :enrollments, :academic_year, :string
    add_column :enrollments, :semester, :integer
  end
end
