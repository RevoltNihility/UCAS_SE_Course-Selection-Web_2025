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
  # 公共必修课
  { name: "大学英语", code: "ENG101", credits: 2, class_hours: 32, teacher: "Smith", course_type: :public_required, max_enrollment: 100, schedule_time: "1:11-12" },
  { name: "中国近代史", code: "HIST101", credits: 2, class_hours: 32, teacher: "钱教授", course_type: :public_required, max_enrollment: 80, schedule_time: "2:11-12" },
  { name: "马克思主义基本原理", code: "PHIL101", credits: 2, class_hours: 32, teacher: "孔教授", course_type: :public_required, max_enrollment: 80, schedule_time: "3:11-12" },
  { name: "大学体育", code: "PE101", credits: 1, class_hours: 32, teacher: "李教练", course_type: :public_required, max_enrollment: 50, schedule_time: "4:11-12" },

  # 公共选修课
  { name: "音乐鉴赏", code: "ART101", credits: 1, class_hours: 16, teacher: "陈老师", course_type: :public_elective, max_enrollment: 60, schedule_time: "5:9-10" },
  { name: "美术鉴赏", code: "ART102", credits: 1, class_hours: 16, teacher: "张老师", course_type: :public_elective, max_enrollment: 60, schedule_time: "5:11-12" },
  { name: "心理学导论", code: "PSY101", credits: 2, class_hours: 32, teacher: "徐教授", course_type: :public_elective, max_enrollment: 70, schedule_time: "1:9-10" },
  { name: "创新创业基础", code: "BUS101", credits: 2, class_hours: 32, teacher: "沈教授", course_type: :public_elective, max_enrollment: 80, schedule_time: "2:9-10" },
  { name: "职业生涯规划", code: "CAR101", credits: 1, class_hours: 16, teacher: "韩老师", course_type: :public_elective, max_enrollment: 50, schedule_time: "3:9-10" },
  { name: "科技论文写作", code: "WRI101", credits: 1, class_hours: 16, teacher: "曹教授", course_type: :public_elective, max_enrollment: 40, schedule_time: "4:9-10" },

  # 专业必修课
  { name: "高等数学A", code: "MATH101", credits: 4, class_hours: 64, teacher: "张教授", course_type: :major_required, max_enrollment: 120, schedule_time: "1:1-2,3:3-4" },
  { name: "线性代数", code: "MATH102", credits: 3, class_hours: 48, teacher: "李教授", course_type: :major_required, max_enrollment: 100, schedule_time: "2:1-2,4:1-2" },
  { name: "大学物理", code: "PHYS101", credits: 4, class_hours: 64, teacher: "王教授", course_type: :major_required, max_enrollment: 100, schedule_time: "1:3-4,3:1-2" },
  { name: "程序设计基础", code: "CS101", credits: 3, class_hours: 48, teacher: "刘教授", course_type: :major_required, max_enrollment: 80, schedule_time: "2:3-4,4:3-4" },
  { name: "数据结构", code: "CS201", credits: 4, class_hours: 64, teacher: "陈教授", course_type: :major_required, max_enrollment: 80, schedule_time: "1:5-6,3:5-6" },
  { name: "计算机组成原理", code: "CS202", credits: 3, class_hours: 48, teacher: "杨教授", course_type: :major_required, max_enrollment: 70, schedule_time: "2:5-6,4:5-6" },
  { name: "操作系统", code: "CS301", credits: 3, class_hours: 48, teacher: "赵教授", course_type: :major_required, max_enrollment: 70, schedule_time: "1:7-8,3:7-8" },
  { name: "计算机网络", code: "CS302", credits: 3, class_hours: 48, teacher: "周教授", course_type: :major_required, max_enrollment: 70, schedule_time: "2:7-8,4:7-8" },

  # 时间冲突的专业必修课（与高等数学A冲突 - 1:1-2）
  { name: "概率论与数理统计", code: "MATH103", credits: 3, class_hours: 48, teacher: "冯教授", course_type: :major_required, max_enrollment: 100, schedule_time: "1:1-2,5:1-2" },

  # 专业选修课
  { name: "机器学习", code: "CS401", credits: 3, class_hours: 48, teacher: "吴教授", course_type: :major_elective, max_enrollment: 50, schedule_time: "1:9-10" },
  { name: "深度学习", code: "CS402", credits: 3, class_hours: 48, teacher: "郑教授", course_type: :major_elective, max_enrollment: 50, schedule_time: "3:9-10" },
  { name: "自然语言处理", code: "CS403", credits: 2, class_hours: 32, teacher: "孙教授", course_type: :major_elective, max_enrollment: 40, schedule_time: "5:1-2" },
  { name: "计算机视觉", code: "CS404", credits: 2, class_hours: 32, teacher: "马教授", course_type: :major_elective, max_enrollment: 40, schedule_time: "5:3-4" },
  { name: "分布式系统", code: "CS405", credits: 3, class_hours: 48, teacher: "朱教授", course_type: :major_elective, max_enrollment: 45, schedule_time: "2:9-10" },
  { name: "云计算技术", code: "CS406", credits: 2, class_hours: 32, teacher: "胡教授", course_type: :major_elective, max_enrollment: 45, schedule_time: "4:9-10" },
  { name: "区块链技术", code: "CS407", credits: 2, class_hours: 32, teacher: "林教授", course_type: :major_elective, max_enrollment: 35, schedule_time: "5:5-6" },
  { name: "软件工程", code: "CS408", credits: 3, class_hours: 48, teacher: "何教授", course_type: :major_elective, max_enrollment: 60, schedule_time: "1:11-12" },
  { name: "数据库系统", code: "CS409", credits: 3, class_hours: 48, teacher: "高教授", course_type: :major_elective, max_enrollment: 60, schedule_time: "3:11-12" },
  { name: "编译原理", code: "CS410", credits: 3, class_hours: 48, teacher: "罗教授", course_type: :major_elective, max_enrollment: 50, schedule_time: "5:7-8" },

  # 时间冲突的专业选修课（与机器学习冲突 - 1:9-10）
  { name: "数据挖掘", code: "CS412", credits: 3, class_hours: 48, teacher: "谢教授", course_type: :major_elective, max_enrollment: 45, schedule_time: "1:9-10" },

  # 时间冲突的专业选修课（与深度学习冲突 - 3:9-10）
  { name: "强化学习", code: "CS413", credits: 2, class_hours: 32, teacher: "唐教授", course_type: :major_elective, max_enrollment: 40, schedule_time: "3:9-10" },

  # 时间冲突的专业选修课（与数据结构冲突 - 1:5-6）
  { name: "算法设计与分析", code: "CS414", credits: 3, class_hours: 48, teacher: "韦教授", course_type: :major_elective, max_enrollment: 50, schedule_time: "1:5-6,2:11-12" },

  # 满员课程（用于测试）- max_enrollment较小，方便测试
  { name: "人工智能导论", code: "CS411", credits: 3, class_hours: 48, teacher: "田教授", course_type: :major_elective, max_enrollment: 30, schedule_time: "5:13" },
  { name: "移动应用开发", code: "CS415", credits: 2, class_hours: 32, teacher: "姜教授", course_type: :major_elective, max_enrollment: 25, schedule_time: "4:11-12" },
  { name: "Web前端开发", code: "CS416", credits: 2, class_hours: 32, teacher: "袁教授", course_type: :major_elective, max_enrollment: 20, schedule_time: "2:13" },
  { name: "游戏开发基础", code: "CS417", credits: 2, class_hours: 32, teacher: "邹教授", course_type: :public_elective, max_enrollment: 15, schedule_time: "3:13" }
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

# 为满员课程创建选课记录
full_courses = ["CS411", "CS415", "CS416", "CS417"]
students = Student.all.to_a

full_courses.each do |course_code|
  course = Course.find_by(code: course_code)
  next unless course

  # 为该课程创建足够的选课记录使其满员
  enrolled_count = 0
  students.shuffle.each do |student|
    break if enrolled_count >= course.max_enrollment

    # 避免重复选课
    unless Enrollment.exists?(student: student, course: course)
      Enrollment.create!(student: student, course: course)
      enrolled_count += 1
    end
  end

  puts "Course #{course.name} (#{course_code}) is now full: #{enrolled_count}/#{course.max_enrollment}"
end

# Create teacher users and link them to courses
# Extract unique teacher names from courses
teacher_names = Course.pluck(:teacher).uniq.compact

teacher_names.each_with_index do |teacher_name, index|
  # Create user account for teacher
  email = "teacher#{index + 1}@university.edu.cn"
  user = User.find_or_create_by!(email: email) do |u|
    u.password = "teacher123"
    u.password_confirmation = "teacher123"
    u.role = :teacher
  end

  # Create teacher record
  teacher_id = "T#{format('%08d', index + 1)}"
  teacher = Teacher.find_or_create_by!(teacher_id: teacher_id) do |t|
    t.user = user
    t.name = teacher_name
    t.email = email
  end

  # Link teacher to their courses through Teaching model
  courses = Course.where(teacher: teacher_name)
  courses.each do |course|
    Teaching.find_or_create_by!(teacher: teacher, course: course) do |teaching|
      teaching.semester = "2024-2025-1"
    end
  end

  puts "Created teacher: #{teacher_name} (#{email}) with #{courses.count} courses"
end

puts "\n=== Seed Data Summary ==="
puts "Created #{Course.count} courses"
puts "Created #{Student.count} students"
puts "Created #{Teacher.count} teachers"
puts "Created #{User.count} users"
puts "Created #{Teaching.count} teaching assignments"
puts "Created enrollments for full courses"
puts "\n=== Test Accounts ==="
puts "Student account: qiuzitao23@mails.ac.cn / correct_password"
puts "Teacher account: teacher1@university.edu.cn / teacher123 (teaches: #{Teacher.first&.courses&.pluck(:name)&.join(', ')})"
