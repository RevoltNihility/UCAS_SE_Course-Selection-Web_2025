class MyCourses::SelectCoursesController < ApplicationController
  before_action :request_logged

  def index
    @student = current_user.student

    # 获取筛选后的课程列表
    @courses = Course.filter_for_selection(
      course_name: params[:course_name],
      course_type: params[:course_type]
    )

    # 准备课程类型选项
    @course_type_options = [
      ['不限', ''],
      ['必修', 'required'],
      ['选修', 'elective'],
      ['公共选修', 'public_elective']
    ]
  end

  def create
    @student = current_user.student
    course = Course.find(params[:course_id])

    # 检查是否已选该课程
    if @student.courses.include?(course)
      flash[:warning] = "您已经选过这门课程了"
      redirect_to my_courses_select_courses_path
      return
    end

    # 检查课程是否满员
    if course.full?
      flash[:danger] = "选课人数已满，无法选课"
      redirect_to my_courses_select_courses_path
      return
    end

    # 创建选课记录
    enrollment = @student.enrollments.build(
      course: course,
      academic_year: "2024-2025",
      semester: :fall,
      course_type: :major_required
    )

    if enrollment.save
      flash[:success] = "选课成功"
    else
      flash[:danger] = "选课失败，请重试"
    end

    redirect_to my_courses_select_courses_path
  end
end

