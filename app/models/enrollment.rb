class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :course

  enum course_type: {
    public_required: 0,   # 公共必修
    public_elective: 1,   # 公共选修
    major_required: 2,    # 专业必修
    major_elective: 3     # 专业选修
  }
end
