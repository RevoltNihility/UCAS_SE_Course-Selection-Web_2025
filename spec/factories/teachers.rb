FactoryBot.define do
  factory :teacher do
    association :user, role: :teacher
    name { "李老师" }
    sequence(:email) { |n| "teacher#{n}@example.ac.cn" }
    sequence(:teacher_id) { |n| "T#{format('%08d', n)}" }
  end
end
