module TeacherCourses
  class CourseStudentsController < ApplicationController
    before_action :request_logged
    before_action :require_teacher

    def show
      @course = Course.find(params[:id])
      @students = @course.students.includes(:enrollments).order(:student_id)
    end

    private

      def require_teacher
        unless current_user.teacher?
          redirect_to root_path, alert: "需要教师权限"
        end
      end
  end
end
