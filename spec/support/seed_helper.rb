module SeedHelper
  def create_seed_students
    Student.create!(name:                  "Zitao Qiu",
                    email:                 "qiuzitao23@mails.ac.cn",
                    student_id:            "2023K8000000000",
                    password:              "correct_password",
                    password_confirmation: "correct_password")
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@educoder.net"
      student_id = "2023K#{format('%010d', n)}"
      password = "password"
      Student.create!(name:                  name,
                      email:                 email,
                      student_id:            student_id,
                      password:              password,
                      password_confirmation: password)
    end
  end
end
