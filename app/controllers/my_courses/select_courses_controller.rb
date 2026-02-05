class MyCourses::SelectCoursesController < ApplicationController
  before_action :request_logged

  def index
    @student = current_user.student

    # 获取筛选后的课程列表
    @courses = Course.filter_for_selection(
      course_name: params[:course_name],
      course_type: params[:course_type],
      schedule_time: params[:schedule_time]
    )

    # 排除学生已选的课程
    if @student
      enrolled_course_ids = @student.courses.pluck(:id)
      @courses = @courses.where.not(id: enrolled_course_ids)
    end

    # 准备课程类型选项
    @course_type_options = [
      [ "不限", "" ],
      [ "公共必修", "public_required" ],
      [ "公共选修", "public_elective" ],
      [ "专业必修", "major_required" ],
      [ "专业选修", "major_elective" ]
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

    # 检查时间冲突
    conflicting_course = @student.courses.find { |enrolled_course| course.conflicts_with?(enrolled_course) }
    if conflicting_course
      flash[:conflict] = "该课程与#{conflicting_course.name}时间冲突"
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
