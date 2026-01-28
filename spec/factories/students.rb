FactoryBot.define do
  factory :student do
    association :user
    name { "张三" }
    sequence(:email) do |n|
      "student#{n}@example.ac.cn"
    end
    sequence(:student_id) do |n|
      "2024K#{format('%010d', n)}"
    end

    trait :enrolled_in_2023 do
      sequence(:student_id) do |n|
        "2023K#{format('%010d', n)}"
      end
    end

    trait :enrolled_in_2025 do
      sequence(:student_id) do |n|
        "2025K#{format('%010d', n)}"
      end
    end
  end
end
