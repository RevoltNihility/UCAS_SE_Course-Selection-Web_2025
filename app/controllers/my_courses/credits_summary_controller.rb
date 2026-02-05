class MyCourses::CreditsSummaryController < ApplicationController
  before_action :request_logged

  def index
    @student = current_user.student

    # 学分要求
    @requirements = {
      public_required: 20,
      public_elective: 15,
      major_required: 15,
      major_elective: 12,
      total: 62
    }

    if @student
      # 计算各类课程的学分总和
      enrollments = @student.enrollments
      @public_required_credits = enrollments.where(course_type: :public_required).joins(:course).sum("courses.credits")
      @public_elective_credits = enrollments.where(course_type: :public_elective).joins(:course).sum("courses.credits")
      @major_required_credits = enrollments.where(course_type: :major_required).joins(:course).sum("courses.credits")
      @major_elective_credits = enrollments.where(course_type: :major_elective).joins(:course).sum("courses.credits")
      @total_credits = @public_required_credits + @public_elective_credits + @major_required_credits + @major_elective_credits
    else
      @public_required_credits = 0
      @public_elective_credits = 0
      @major_required_credits = 0
      @major_elective_credits = 0
      @total_credits = 0
    end
  end
end
