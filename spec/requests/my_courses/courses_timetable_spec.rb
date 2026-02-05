require 'rails_helper'

RSpec.describe "MyCourses::CoursesTimetable", type: :request do
  let(:user) { create(:user) }
  let(:student) { create(:student, user: user) }
  let(:course1) { create(:course, name: "高等数学", schedule_time: "1:1-2,3:3-4") }
  let(:course2) { create(:course, name: "线性代数", schedule_time: "2:1-2") }
  let(:course3) { create(:course, name: "数据结构", schedule_time: "5:5-7") }

  before do
    # 创建选课记录
    create(:enrollment, student: student, course: course1)
    create(:enrollment, student: student, course: course2)
    create(:enrollment, student: student, course: course3)

    # 模拟用户登录
    post login_path, params: { session: { email: user.email, password: "password123" } }
  end

  describe "GET /index" do
    it "returns http success" do
      get my_courses_courses_timetable_index_path
      expect(response).to have_http_status(:success)
    end

    it "assigns @courses with student's enrolled courses" do
      get my_courses_courses_timetable_index_path
      expect(assigns(:courses)).to be_an(Array)
      expect(assigns(:courses).count).to eq(3)
      expect(assigns(:courses).map(&:name)).to include("高等数学", "线性代数", "数据结构")
    end

    context "when user is not logged in" do
      before do
        delete logout_path
      end

      it "redirects to login page" do
        get my_courses_courses_timetable_index_path
        expect(response).to redirect_to(login_path)
      end
    end

    context "when user has no student record" do
      it "handles gracefully" do
        user_without_student = create(:user, email: "nostudent@example.com")
        post login_path, params: { session: { email: user_without_student.email, password: "password123" } }

        get my_courses_courses_timetable_index_path
        expect(response).to have_http_status(:success)
        expect(assigns(:courses)).to eq([])
      end
    end

    context "sidebar navigation" do
      it "renders the sidebar with navigation items" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include("已选课程")
        expect(response.body).to include("选择课程")
      end
    end
  end
end
