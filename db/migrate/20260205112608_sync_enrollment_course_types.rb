class SyncEnrollmentCourseTypes < ActiveRecord::Migration[8.1]
  def up
    # 将所有选课记录的 course_type 同步为对应课程的 course_type
    Enrollment.find_each do |enrollment|
      if enrollment.course
        enrollment.update_column(:course_type, enrollment.course.course_type)
      end
    end
  end

  def down
    # 数据迁移不可逆
    raise ActiveRecord::IrreversibleMigration
  end
end
