class Course < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments

  # 课程类型枚举
  enum :course_type, { required: 0, elective: 1, public_elective: 2 }

  # 验证
  validates :max_enrollment, numericality: { greater_than: 0 }

  # 计算已选人数
  def enrolled_count
    enrollments.count
  end

  # 判断是否满员
  def full?
    enrolled_count >= max_enrollment
  end

  # 获取可选课程列表
  scope :available_for_selection, ->(semester) { order(:name) }

  # 筛选课程
  def self.filter_for_selection(course_name:, course_type:)
    courses = all

    # 按课程名称筛选（模糊搜索）
    if course_name.present?
      courses = courses.where("name LIKE ?", "%#{course_name}%")
    end

    # 按课程类型筛选
    if course_type.present?
      courses = courses.where(course_type: course_type)
    end

    courses.order(:name)
  end

  # 课程类型中文翻译
  def course_type_i18n
    I18n.t("activerecord.attributes.course.course_types.#{course_type}")
  end
end
