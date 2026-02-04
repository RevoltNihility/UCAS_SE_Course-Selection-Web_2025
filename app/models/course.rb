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
end
