require 'rails_helper'

RSpec.describe "MyCourses::SelectCourses", type: :request do
  let(:user) { create(:user, role: :student) }
  let(:student) { create(:student, user: user) }

  before do
    student # 确保 student 被创建
    # 模拟用户登录
    post login_path, params: { session: { email: user.email, password: "password123" } }
  end

  describe "GET /my_courses/select_courses" do
    let!(:course1) { create(:course, name: "高等数学", course_type: :major_required) }
    let!(:course2) { create(:course, name: "线性代数", course_type: :major_required) }
    let!(:course3) { create(:course, name: "机器学习", course_type: :major_elective) }

    it "returns http success" do
      get my_courses_select_courses_path
      expect(response).to have_http_status(:success)
    end

    it "displays all courses" do
      get my_courses_select_courses_path
      expect(response.body).to include("高等数学")
      expect(response.body).to include("线性代数")
      expect(response.body).to include("机器学习")
    end

    context "when student has already enrolled in some courses" do
      before do
        create(:enrollment, student: student, course: course1)
      end

      it "does not display enrolled courses" do
        get my_courses_select_courses_path
        expect(response.body).not_to include("高等数学")
        expect(response.body).to include("线性代数")
        expect(response.body).to include("机器学习")
      end

      it "only shows available courses count" do
        get my_courses_select_courses_path
        expect(assigns(:courses).count).to eq(2)
      end
    end

    it "filters courses by name" do
      get my_courses_select_courses_path, params: { course_name: "数学" }
      expect(response.body).to include("高等数学")
      expect(response.body).not_to include("机器学习")
    end

    it "filters courses by type" do
      get my_courses_select_courses_path, params: { course_type: "major_elective" }
      expect(response.body).to include("机器学习")
      expect(response.body).not_to include("高等数学")
    end

    it "displays enrollment count" do
      get my_courses_select_courses_path
      expect(response.body).to include("0/100")
    end

    context "when course is full" do
      let!(:full_course) { create(:course, name: "满员课程", max_enrollment: 2) }
      let!(:other_student1) { create(:student) }
      let!(:other_student2) { create(:student) }

      before do
        create(:enrollment, student: other_student1, course: full_course)
        create(:enrollment, student: other_student2, course: full_course)
      end

      it "displays full status" do
        get my_courses_select_courses_path
        expect(response.body).to include("2/2")
        expect(response.body).to include("选课人数已满")
      end
    end
  end

  describe "POST /my_courses/select_courses" do
    let(:course) { create(:course, name: "测试课程", max_enrollment: 50) }

    context "when successfully enrolling" do
      it "creates an enrollment record" do
        expect {
          post my_courses_select_courses_path, params: { course_id: course.id }
        }.to change(Enrollment, :count).by(1)
      end

      it "redirects to select_courses page" do
        post my_courses_select_courses_path, params: { course_id: course.id }
        expect(response).to redirect_to(my_courses_select_courses_path)
      end

      it "displays success message" do
        post my_courses_select_courses_path, params: { course_id: course.id }
        follow_redirect!
        expect(response.body).to include("选课成功")
      end
    end

    context "when course is already enrolled" do
      before do
        create(:enrollment, student: student, course: course)
      end

      it "does not create duplicate enrollment" do
        expect {
          post my_courses_select_courses_path, params: { course_id: course.id }
        }.not_to change(Enrollment, :count)
      end

      it "displays warning message" do
        post my_courses_select_courses_path, params: { course_id: course.id }
        follow_redirect!
        expect(response.body).to include("您已经选过这门课程了")
      end
    end

    context "when course is full" do
      let(:full_course) { create(:course, name: "满员课程", max_enrollment: 1) }
      let(:other_student) { create(:student) }

      before do
        create(:enrollment, student: other_student, course: full_course)
      end

      it "does not create enrollment" do
        expect {
          post my_courses_select_courses_path, params: { course_id: full_course.id }
        }.not_to change(Enrollment, :count)
      end

      it "displays error message" do
        post my_courses_select_courses_path, params: { course_id: full_course.id }
        follow_redirect!
        expect(response.body).to include("选课人数已满")
      end
    end

    context "when course has time conflict with enrolled courses" do
      let(:enrolled_course) { create(:course, name: "已选课程", schedule_time: "1:1-2,3:4-6") }
      let(:conflict_course1) { create(:course, name: "冲突课程1", schedule_time: "1:2-3") }
      let(:conflict_course2) { create(:course, name: "冲突课程2", schedule_time: "3:5-7") }
      let(:no_conflict_course) { create(:course, name: "不冲突课程", schedule_time: "2:1-2") }

      before do
        create(:enrollment, student: student, course: enrolled_course)
      end

      it "does not create enrollment when time conflicts" do
        expect {
          post my_courses_select_courses_path, params: { course_id: conflict_course1.id }
        }.not_to change(Enrollment, :count)
      end

      it "displays conflict error message with course name" do
        post my_courses_select_courses_path, params: { course_id: conflict_course1.id }
        follow_redirect!
        expect(response.body).to include("该课程与已选课程时间冲突")
        expect(response.body).to include("已选课程")
        expect(response.body).to include("flash-conflict")
      end

      it "detects conflict in different time slot" do
        expect {
          post my_courses_select_courses_path, params: { course_id: conflict_course2.id }
        }.not_to change(Enrollment, :count)
      end

      it "allows enrollment when no time conflict" do
        expect {
          post my_courses_select_courses_path, params: { course_id: no_conflict_course.id }
        }.to change(Enrollment, :count).by(1)
      end
    end
  end

  describe "sidebar navigation" do
    it "renders the sidebar with navigation items" do
      get my_courses_select_courses_path
      expect(response.body).to include("已选课程")
      expect(response.body).to include("选择课程")
    end

    it "highlights the current page in sidebar" do
      get my_courses_select_courses_path
      expect(response.body).to include("sidebar-item active")
    end
  end
end
