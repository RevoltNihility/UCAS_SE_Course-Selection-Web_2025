FactoryBot.define do
  factory :teaching do
    association :teacher
    association :course
    semester { "2024-2025-1" }
  end
end
