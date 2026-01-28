FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "课程#{n}" }
    sequence(:code) { |n| "COURSE#{format('%03d', n)}" }
    credits { 3 }
    class_hours { 48 }
    teacher { "张老师" }

    trait :with_high_credits do
      credits { 4 }
      class_hours { 64 }
    end

    trait :with_low_credits do
      credits { 2 }
      class_hours { 32 }
    end
  end
end
