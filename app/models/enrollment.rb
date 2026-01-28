class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :course

  enum :course_type, {
    public_required: 0,   # 公共必修
    public_elective: 1,   # 公共选修
    major_required: 2,    # 专业必修
    major_elective: 3     # 专业选修
  }

  enum :semester, {
    fall: 0,    # 秋季学期
    spring: 1,  # 春季学期
    summer: 2   # 夏季学期
  }

  # 学期中文映射
  SEMESTER_CHINESE = {
    "fall" => "秋",
    "spring" => "春",
    "summer" => "夏"
  }.freeze

  # 排序 scope: 按学年降序、学期降序、课程类型升序
  scope :ordered, -> {
    order(academic_year: :desc, semester: :desc, course_type: :asc)
  }

  # 返回格式化的学期显示字符串
  def semester_display
    return nil if academic_year.nil?
    return academic_year if semester.nil?

    "#{academic_year}#{SEMESTER_CHINESE[semester]}"
  end
end
