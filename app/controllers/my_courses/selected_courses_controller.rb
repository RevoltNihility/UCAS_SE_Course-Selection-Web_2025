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

  def destroy
    @student = current_user.student
    enrollment = Enrollment.find(params[:id])

    # 检查该选课记录是否属于当前学生
    if enrollment.student_id != @student.id
      flash[:danger] = "无权退选该课程"
      redirect_to my_courses_selected_courses_path
      return
    end

    if enrollment.destroy
      flash[:success] = "退课成功"
    else
      flash[:danger] = "退课失败，请重试"
    end

    redirect_to my_courses_selected_courses_path
  end
end
