module MyCourses::SelectedCoursesHelper
  # 格式化学时和学分显示
  # @param course [Course] 课程对象
  # @return [String] 格式化后的字符串,如 "48/3"
  def format_class_hours_credits(course)
    class_hours = course.class_hours || "-"
    credits = course.credits ? format_credits(course.credits) : "-"
    "#{class_hours}/#{credits}"
  end

  private

  # 格式化学分，去除不必要的小数点
  # @param credits [Numeric] 学分数值
  # @return [String] 格式化后的学分字符串
  def format_credits(credits)
    credits % 1 == 0 ? credits.to_i.to_s : credits.to_s
  end
end
