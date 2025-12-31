class MyCourses::SelectedCoursesController < ApplicationController
  include SessionsHelper

  before_action :request_logged

  def index
    @student = current_user
    @courses = @student.courses
  end

  private
    def request_logged
      unless logged_in?
        store_location
        flash[:danger] = "请登录后重试"
        redirect_to :login
      end
    end
end
