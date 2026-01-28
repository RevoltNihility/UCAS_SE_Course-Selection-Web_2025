FactoryBot.define do
  factory :enrollment do
    association :student
    association :course
    academic_year { "2024-2025" }
    semester { :fall }
    course_type { :public_required }
    grade { nil }

    trait :spring_semester do
      semester { :spring }
    end

    trait :summer_semester do
      semester { :summer }
    end

    trait :public_elective do
      course_type { :public_elective }
    end

    trait :major_required do
      course_type { :major_required }
    end

    trait :major_elective do
      course_type { :major_elective }
    end

    trait :with_grade do
      grade { rand(60..100) }
    end
  end
end
