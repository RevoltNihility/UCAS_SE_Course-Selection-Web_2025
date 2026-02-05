module TeacherCourses
  class TeachingCoursesController < ApplicationController
    before_action :request_logged
    before_action :require_teacher

    def index
      @teacher = current_user.teacher
      @courses = @teacher.courses.includes(:teachings).order(:name)
    end

    private

      def require_teacher
        unless current_user.teacher?
          redirect_to root_path, alert: "需要教师权限"
        end
      end
  end
end
