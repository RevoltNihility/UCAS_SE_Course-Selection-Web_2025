FactoryBot.define do
  factory :student do
    name       { "San Zhang" }
    sequence(:email) do |n|
      "zhangsan#{n}@example.ac.cn"
    end
    sequence(:student_id) do |n|
      "2023K#{format('%010d', n)}"
    end
    password { "testpassword" }
    password_confirmation { "testpassword" }
  end
end
