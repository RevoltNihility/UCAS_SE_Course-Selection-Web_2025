class Course < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments

  # 课程类型枚举
  enum :course_type, {
    public_required: 0,   # 公共必修
    public_elective: 1,   # 公共选修
    major_required: 2,    # 专业必修
    major_elective: 3     # 专业选修
  }

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
  def self.filter_for_selection(course_name:, course_type:, schedule_time: nil)
    courses = all

    # 按课程名称筛选（模糊搜索）
    if course_name.present?
      courses = courses.where("name LIKE ?", "%#{course_name}%")
    end

    # 按课程类型筛选
    if course_type.present?
      courses = courses.where(course_type: course_type)
    end

    # 按上课时间筛选
    if schedule_time.present?
      courses = courses.where("schedule_time LIKE ?", "%#{schedule_time}%")
    end

    courses.order(:name)
  end

  # 课程类型中文翻译
  def course_type_i18n
    I18n.t("activerecord.attributes.course.course_types.#{course_type}")
  end

  # 解析上课时间为结构化数据
  # 返回格式: [{day: 1, periods: [1, 2]}, {day: 3, periods: [4, 5, 6]}]
  def parsed_schedule
    return [] if schedule_time.blank?

    schedule_time.split(",").map do |time_slot|
      day, periods = time_slot.split(":")
      next if day.blank? || periods.blank?

      period_range = periods.split("-").map(&:to_i)
      {
        day: day.to_i,
        periods: period_range.size == 2 ? (period_range[0]..period_range[1]).to_a : [ period_range[0] ]
      }
    end.compact
  end

  # 格式化显示上课时间
  # 例如: "周一 1-2节, 周三 4-6节"
  def formatted_schedule
    return "未安排" if schedule_time.blank?

    day_names = %w[周日 周一 周二 周三 周四 周五 周六 周日]

    parsed_schedule.map do |slot|
      day_name = day_names[slot[:day]]
      periods = slot[:periods]
      period_str = periods.size > 1 ? "#{periods.first}-#{periods.last}节" : "#{periods.first}节"
      "#{day_name} #{period_str}"
    end.join(", ")
  end

  # 检测与另一门课程是否有时间冲突
  def conflicts_with?(other_course)
    return false if schedule_time.blank? || other_course.schedule_time.blank?

    my_schedule = parsed_schedule
    other_schedule = other_course.parsed_schedule

    my_schedule.any? do |my_slot|
      other_schedule.any? do |other_slot|
        # 同一天且有节次重叠
        my_slot[:day] == other_slot[:day] && (my_slot[:periods] & other_slot[:periods]).any?
      end
    end
  end
end
