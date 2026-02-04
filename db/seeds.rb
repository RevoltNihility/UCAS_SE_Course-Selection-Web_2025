# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a test user with associated student
user = User.find_or_create_by!(email: "qiuzitao23@mails.ac.cn") do |u|
  u.password = "correct_password"
  u.password_confirmation = "correct_password"
  u.role = :student
end

Student.find_or_create_by!(student_id: "2023K8000000000") do |s|
  s.user = user
  s.name = "Zitao Qiu"
  s.email = "qiuzitao23@mails.ac.cn"
end

# Create 99 more users with students
99.times do |n|
  email = "example-#{n+1}@educoder.net"
  student_id = "2023K#{format('%010d', n + 1)}"

  user = User.find_or_create_by!(email: email) do |u|
    u.password = "password"
    u.password_confirmation = "password"
    u.role = :student
  end

  Student.find_or_create_by!(student_id: student_id) do |s|
    s.user = user
    s.name = Faker::Name.name
    s.email = email
  end
end

# Create courses with various attributes
courses_data = [
  # 必修课
  { name: "高等数学A", code: "MATH101", credits: 4, class_hours: 64, teacher: "张教授", course_type: :required, max_enrollment: 120, schedule_time: "周一 1-2节, 周三 3-4节" },
  { name: "线性代数", code: "MATH102", credits: 3, class_hours: 48, teacher: "李教授", course_type: :required, max_enrollment: 100, schedule_time: "周二 1-2节, 周四 1-2节" },
  { name: "大学物理", code: "PHYS101", credits: 4, class_hours: 64, teacher: "王教授", course_type: :required, max_enrollment: 100, schedule_time: "周一 3-4节, 周三 1-2节" },
  { name: "程序设计基础", code: "CS101", credits: 3, class_hours: 48, teacher: "刘教授", course_type: :required, max_enrollment: 80, schedule_time: "周二 3-4节, 周四 3-4节" },
  { name: "数据结构", code: "CS201", credits: 4, class_hours: 64, teacher: "陈教授", course_type: :required, max_enrollment: 80, schedule_time: "周一 5-6节, 周三 5-6节" },
  { name: "计算机组成原理", code: "CS202", credits: 3, class_hours: 48, teacher: "杨教授", course_type: :required, max_enrollment: 70, schedule_time: "周二 5-6节, 周四 5-6节" },
  { name: "操作系统", code: "CS301", credits: 3, class_hours: 48, teacher: "赵教授", course_type: :required, max_enrollment: 70, schedule_time: "周一 7-8节, 周三 7-8节" },
  { name: "计算机网络", code: "CS302", credits: 3, class_hours: 48, teacher: "周教授", course_type: :required, max_enrollment: 70, schedule_time: "周二 7-8节, 周四 7-8节" },

  # 选修课
  { name: "机器学习", code: "CS401", credits: 3, class_hours: 48, teacher: "吴教授", course_type: :elective, max_enrollment: 50, schedule_time: "周一 9-10节" },
  { name: "深度学习", code: "CS402", credits: 3, class_hours: 48, teacher: "郑教授", course_type: :elective, max_enrollment: 50, schedule_time: "周三 9-10节" },
  { name: "自然语言处理", code: "CS403", credits: 2, class_hours: 32, teacher: "孙教授", course_type: :elective, max_enrollment: 40, schedule_time: "周五 1-2节" },
  { name: "计算机视觉", code: "CS404", credits: 2, class_hours: 32, teacher: "马教授", course_type: :elective, max_enrollment: 40, schedule_time: "周五 3-4节" },
  { name: "分布式系统", code: "CS405", credits: 3, class_hours: 48, teacher: "朱教授", course_type: :elective, max_enrollment: 45, schedule_time: "周二 9-10节" },
  { name: "云计算技术", code: "CS406", credits: 2, class_hours: 32, teacher: "胡教授", course_type: :elective, max_enrollment: 45, schedule_time: "周四 9-10节" },
  { name: "区块链技术", code: "CS407", credits: 2, class_hours: 32, teacher: "林教授", course_type: :elective, max_enrollment: 35, schedule_time: "周五 5-6节" },
  { name: "软件工程", code: "CS408", credits: 3, class_hours: 48, teacher: "何教授", course_type: :elective, max_enrollment: 60, schedule_time: "周一 11-12节" },
  { name: "数据库系统", code: "CS409", credits: 3, class_hours: 48, teacher: "高教授", course_type: :elective, max_enrollment: 60, schedule_time: "周三 11-12节" },
  { name: "编译原理", code: "CS410", credits: 3, class_hours: 48, teacher: "罗教授", course_type: :elective, max_enrollment: 50, schedule_time: "周五 7-8节" },

  # 公共选修课
  { name: "大学英语", code: "ENG101", credits: 2, class_hours: 32, teacher: "Smith", course_type: :public_elective, max_enrollment: 100, schedule_time: "周一 13-14节" },
  { name: "中国近代史", code: "HIST101", credits: 2, class_hours: 32, teacher: "钱教授", course_type: :public_elective, max_enrollment: 80, schedule_time: "周二 13-14节" },
  { name: "马克思主义基本原理", code: "PHIL101", credits: 2, class_hours: 32, teacher: "孔教授", course_type: :public_elective, max_enrollment: 80, schedule_time: "周三 13-14节" },
  { name: "大学体育", code: "PE101", credits: 1, class_hours: 32, teacher: "李教练", course_type: :public_elective, max_enrollment: 50, schedule_time: "周四 13-14节" },
  { name: "音乐鉴赏", code: "ART101", credits: 1, class_hours: 16, teacher: "陈老师", course_type: :public_elective, max_enrollment: 60, schedule_time: "周五 9-10节" },
  { name: "美术鉴赏", code: "ART102", credits: 1, class_hours: 16, teacher: "张老师", course_type: :public_elective, max_enrollment: 60, schedule_time: "周五 11-12节" },
  { name: "心理学导论", code: "PSY101", credits: 2, class_hours: 32, teacher: "徐教授", course_type: :public_elective, max_enrollment: 70, schedule_time: "周一 15-16节" },
  { name: "创新创业基础", code: "BUS101", credits: 2, class_hours: 32, teacher: "沈教授", course_type: :public_elective, max_enrollment: 80, schedule_time: "周二 15-16节" },
  { name: "职业生涯规划", code: "CAR101", credits: 1, class_hours: 16, teacher: "韩老师", course_type: :public_elective, max_enrollment: 50, schedule_time: "周三 15-16节" },
  { name: "科技论文写作", code: "WRI101", credits: 1, class_hours: 16, teacher: "曹教授", course_type: :public_elective, max_enrollment: 40, schedule_time: "周四 15-16节" },

  # 一些满员的课程（用于测试）
  { name: "人工智能导论", code: "CS411", credits: 3, class_hours: 48, teacher: "田教授", course_type: :elective, max_enrollment: 30, schedule_time: "周五 13-14节" },
]

courses_data.each do |course_attrs|
  Course.find_or_create_by!(code: course_attrs[:code]) do |c|
    c.name = course_attrs[:name]
    c.credits = course_attrs[:credits]
    c.class_hours = course_attrs[:class_hours]
    c.teacher = course_attrs[:teacher]
    c.course_type = course_attrs[:course_type]
    c.max_enrollment = course_attrs[:max_enrollment]
    c.schedule_time = course_attrs[:schedule_time]
  end
end

puts "Created #{Course.count} courses"
puts "Created #{Student.count} students"
puts "Created #{User.count} users"

