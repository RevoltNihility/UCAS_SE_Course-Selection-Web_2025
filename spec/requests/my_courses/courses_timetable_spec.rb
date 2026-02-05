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

    context "timetable structure" do
      it "renders a timetable table" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include('<table class="timetable">')
      end

      it "renders weekday headers" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include("周一")
        expect(response.body).to include("周二")
        expect(response.body).to include("周三")
        expect(response.body).to include("周四")
        expect(response.body).to include("周五")
        expect(response.body).to include("周六")
        expect(response.body).to include("周日")
      end

      it "renders period numbers 1-13" do
        get my_courses_courses_timetable_index_path
        (1..13).each do |period|
          expect(response.body).to include(">#{period}<")
        end
      end

      it "renders courses in correct time slots" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include("高等数学")
        expect(response.body).to include("线性代数")
        expect(response.body).to include("数据结构")
      end
    end
  end

  describe "Integration: Complete user flow" do
    context "accessing timetable from sidebar" do
      it "allows navigation from selected_courses page" do
        get my_courses_selected_courses_path
        expect(response.body).to include("课程时间表")
        expect(response.body).to include(my_courses_courses_timetable_index_path)

        get my_courses_courses_timetable_index_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("课程时间表")
      end

      it "allows navigation from select_courses page" do
        get my_courses_select_courses_path
        expect(response.body).to include("课程时间表")
        expect(response.body).to include(my_courses_courses_timetable_index_path)

        get my_courses_courses_timetable_index_path
        expect(response).to have_http_status(:success)
      end
    end

    context "accessing timetable from selected_courses button" do
      it "navigates to timetable when clicking the button" do
        get my_courses_selected_courses_path
        expect(response.body).to include("查看本学期课表")
        expect(response.body).to include(my_courses_courses_timetable_index_path)

        get my_courses_courses_timetable_index_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("高等数学")
      end
    end

    context "with multiple courses at different times" do
      it "displays all courses in correct positions" do
        get my_courses_courses_timetable_index_path

        # 验证课程出现在页面中
        expect(response.body).to include("高等数学")
        expect(response.body).to include("线性代数")
        expect(response.body).to include("数据结构")

        # 验证有课程方块样式
        expect(response.body).to include('class="course-cell"')
        expect(response.body).to include('rowspan=')
      end
    end

    context "with no enrolled courses" do
      let(:new_user) { create(:user, email: "newuser@example.com") }
      let(:new_student) { create(:student, user: new_user) }

      before do
        delete logout_path
        post login_path, params: { session: { email: new_user.email, password: "password123" } }
      end

      it "displays empty state with link to select courses" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include("暂无选课记录")
        expect(response.body).to include("去选课")
        expect(response.body).to include(my_courses_select_courses_path)
      end

      it "allows navigation to select_courses page" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include(my_courses_select_courses_path)

        get my_courses_select_courses_path
        expect(response).to have_http_status(:success)
      end
    end

    context "course details in tooltip" do
      it "includes course code, name, and teacher in title attribute" do
        get my_courses_courses_timetable_index_path

        # 验证tooltip包含课程详细信息
        expect(response.body).to match(/title="[^"]*#{course1.code}[^"]*#{course1.name}[^"]*#{course1.teacher}[^"]*"/)
      end
    end

    context "multi-period courses" do
      let(:long_course) { create(:course, name: "体育课", schedule_time: "4:1-3") }

      before do
        create(:enrollment, student: student, course: long_course)
      end

      it "displays courses spanning multiple periods with rowspan" do
        get my_courses_courses_timetable_index_path
        expect(response.body).to include("体育课")
        expect(response.body).to include('rowspan="3"')
      end
    end
  end
end
