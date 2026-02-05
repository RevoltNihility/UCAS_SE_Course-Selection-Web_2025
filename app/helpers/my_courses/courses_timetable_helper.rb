module MyCourses::CoursesTimetableHelper
  # 预定义的课程颜色数组
  COURSE_COLORS = [
    '#FFB6C1', # 浅粉色
    '#B0E0E6', # 浅蓝色
    '#98FB98', # 浅绿色
    '#FFD700', # 金色
    '#DDA0DD', # 梅红色
    '#F0E68C', # 卡其色
    '#FFA07A', # 浅橙色
    '#87CEEB', # 天蓝色
    '#F08080', # 浅珊瑚色
    '#E0BBE4'  # 淡紫色
  ].freeze

  # 为课程分配颜色
  def course_color(course_index)
    COURSE_COLORS[course_index % COURSE_COLORS.length]
  end

  # 构建时间表数据结构
  # 返回格式: { day => { period => { course:, color:, span_start:, rowspan: } } }
  def build_timetable_data(courses)
    timetable = {}
    course_color_map = {}

    courses.each_with_index do |course, index|
      # 跳过没有时间安排的课程
      next if course.schedule_time.blank?

      # 为课程分配颜色
      course_color_map[course.id] = course_color(index)

      # 解析课程时间
      parsed = course.parsed_schedule

      parsed.each do |slot|
        day = slot[:day]
        periods = slot[:periods]

        # 初始化day的hash
        timetable[day] ||= {}

        # 为每个节次创建数据
        periods.each_with_index do |period, period_index|
          timetable[day][period] = {
            course: course,
            color: course_color_map[course.id],
            span_start: period_index == 0, # 只有第一个节次是span_start
            rowspan: period_index == 0 ? periods.length : 1 # 只有第一个节次有rowspan
          }
        end
      end
    end

    timetable
  end
end
