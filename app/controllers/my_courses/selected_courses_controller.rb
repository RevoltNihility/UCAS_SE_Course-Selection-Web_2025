class MyCourses::SelectedCoursesController < ApplicationController
  before_action :request_logged

  def index
    @student = current_user.student
    @courses = @student&.courses || []
  end
end
