class Student < ApplicationRecord
  belongs_to :user
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "Name Format Invalid" }
  validates :student_id, presence: true, uniqueness: true, format: { with: /\A\d{4}K\d{10}\z/, message: "Student_id Format Invalid" }

  # 从学号中提取入学年份
  def enrollment_year
    return nil if student_id.nil? || student_id.length < 4
    student_id[0..3].to_i
  end

  # 获取从入学到当前的所有可选学期列表
  # @return [Array<String>] 学期列表,格式如 ["2024-2025秋", "2024-2025春"]
  def available_semesters
    return [] if enrollment_year.nil?

    today = Date.today
    current_year = today.year
    current_month = today.month

    # 确定当前所在的学年
    # 如果当前月份 >= 9,说明新学年的秋季学期已经开始
    # 否则还在上一学年的春季学期
    current_academic_year_start = current_month >= 9 ? current_year : current_year - 1

    # 确定起始学年:取入学年份和当前学年中较早的一个
    start_year = [ enrollment_year, current_academic_year_start ].min

    semesters = []

    # 从起始年份到当前学年,生成所有学期
    (start_year..current_academic_year_start).each do |year|
      academic_year = "#{year}-#{year + 1}"
      semesters << "#{academic_year}秋"
      semesters << "#{academic_year}春"
    end

    semesters
  end

  # 筛选选课记录
  # @param semester [String] 学期字符串,格式如 "2024-2025秋"
  # @param course_name [String] 课程名称,支持模糊搜索
  # @return [ActiveRecord::Relation] 筛选并排序后的选课记录
  def enrollments_filtered(semester: nil, course_name: nil)
    result = enrollments.ordered

    # 如果需要按课程名称筛选,需要 join courses 表
    if course_name.present?
      result = result.joins(:course)
    else
      result = result.includes(:course)
    end

    # 按学期筛选
    if semester.present?
      # 解析学期字符串,如 "2024-2025秋"
      academic_year = semester[0..8]  # "2024-2025"
      semester_char = semester[9] if semester.length > 9  # "秋"

      # 将中文字符映射回 enum 值
      semester_enum = case semester_char
      when "秋" then "fall"
      when "春" then "spring"
      when "夏" then "summer"
      end

      result = result.where(academic_year: academic_year, semester: semester_enum)
    end

    # 按课程名称筛选(模糊搜索)
    if course_name.present?
      result = result.where("courses.name LIKE ?", "%#{sanitize_sql_like(course_name)}%")
    end

    result
  end

  private

    # 转义 SQL LIKE 查询中的特殊字符
    def sanitize_sql_like(string)
      string.gsub(/[%_]/, '\\\\\0')
    end
end
