class MyCourses::SelectedCoursesController < ApplicationController
  before_action :request_logged

  def index
    @student = current_user.student

    if @student
      @enrollments = @student.enrollments_filtered(
        semester: params[:semester],
        course_name: params[:course_name]
      )
      @available_semesters = @student.available_semesters
    else
      @enrollments = []
      @available_semesters = []
    end
  end
end
