module MyCourses
  class CoursesTimetableController < ApplicationController
    before_action :request_logged

    def index
      @student = current_user.student

      if @student
        # 获取学生已选的所有课程
        @courses = @student.enrollments.includes(:course).map(&:course)
      else
        @courses = []
      end
    end
  end
end
