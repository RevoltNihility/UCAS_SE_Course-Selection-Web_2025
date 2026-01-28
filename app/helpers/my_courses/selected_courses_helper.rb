module MyCourses::SelectedCoursesHelper
  # 格式化学时和学分显示
  # @param course [Course] 课程对象
  # @return [String] 格式化后的字符串,如 "48/3"
  def format_class_hours_credits(course)
    class_hours = course.class_hours || "-"
    credits = course.credits || "-"
    "#{class_hours}/#{credits}"
  end
end
