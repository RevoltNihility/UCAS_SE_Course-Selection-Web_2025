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
