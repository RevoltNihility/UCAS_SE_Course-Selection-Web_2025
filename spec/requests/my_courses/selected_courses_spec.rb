require 'rails_helper'

RSpec.describe "MyCourses::SelectedCourses", type: :request do
  let(:user) { create(:user) }
  let(:student) { create(:student, user: user) }
  let(:course1) { create(:course, name: "高等数学") }
  let(:course2) { create(:course, name: "线性代数") }
  let(:course3) { create(:course, name: "数据结构") }

  before do
    # 创建选课记录
    create(:enrollment, student: student, course: course1,
           academic_year: "2024-2025", semester: :fall, course_type: :public_required)
    create(:enrollment, student: student, course: course2,
           academic_year: "2024-2025", semester: :spring, course_type: :public_elective)
    create(:enrollment, student: student, course: course3,
           academic_year: "2025-2026", semester: :fall, course_type: :major_required)

    # 模拟用户登录
    post login_path, params: { session: { email: user.email, password: "password123" } }
  end

  describe "GET /index" do
    it "returns http success" do
      get my_courses_selected_courses_path
      expect(response).to have_http_status(:success)
    end

    context "without filter parameters" do
      it "returns all enrollments ordered" do
        get my_courses_selected_courses_path
        expect(assigns(:enrollments).count).to eq(3)
        # 验证排序:2025-2026秋 > 2024-2025春 > 2024-2025秋
        expect(assigns(:enrollments).first.course.name).to eq("数据结构")
      end

      it "sets available_semesters instance variable" do
        get my_courses_selected_courses_path
        expect(assigns(:available_semesters)).to be_an(Array)
        expect(assigns(:available_semesters)).not_to be_empty
      end
    end

    context "with semester parameter" do
      it "returns only enrollments from specified semester" do
        get my_courses_selected_courses_path, params: { semester: "2024-2025秋" }
        expect(assigns(:enrollments).count).to eq(1)
        expect(assigns(:enrollments).first.course.name).to eq("高等数学")
      end

      it "returns empty when no match" do
        get my_courses_selected_courses_path, params: { semester: "2022-2023秋" }
        expect(assigns(:enrollments)).to be_empty
      end
    end

    context "with course_name parameter" do
      it "returns enrollments with matching course names" do
        get my_courses_selected_courses_path, params: { course_name: "数" }
        expect(assigns(:enrollments).count).to eq(3)
      end

      it "returns specific course when exact match" do
        get my_courses_selected_courses_path, params: { course_name: "数据结构" }
        expect(assigns(:enrollments).count).to eq(1)
        expect(assigns(:enrollments).first.course.name).to eq("数据结构")
      end

      it "returns empty when no match" do
        get my_courses_selected_courses_path, params: { course_name: "物理" }
        expect(assigns(:enrollments)).to be_empty
      end
    end

    context "with both semester and course_name parameters" do
      it "returns enrollments matching both conditions" do
        get my_courses_selected_courses_path, params: { semester: "2024-2025秋", course_name: "数学" }
        expect(assigns(:enrollments).count).to eq(1)
        expect(assigns(:enrollments).first.course.name).to eq("高等数学")
      end

      it "returns empty when only one condition matches" do
        get my_courses_selected_courses_path, params: { semester: "2024-2025秋", course_name: "物理" }
        expect(assigns(:enrollments)).to be_empty
      end
    end

    context "when user has no student record" do
      it "handles gracefully" do
        user_without_student = create(:user, email: "nostudent@example.com")
        post login_path, params: { session: { email: user_without_student.email, password: "password123" } }

        get my_courses_selected_courses_path
        expect(response).to have_http_status(:success)
        expect(assigns(:enrollments)).to eq([])
      end
    end

    context "sidebar navigation" do
      it "renders the sidebar with navigation items" do
        get my_courses_selected_courses_path
        expect(response.body).to include("已选课程")
        expect(response.body).to include("选择课程")
      end

      it "includes link to selected courses page" do
        get my_courses_selected_courses_path
        expect(response.body).to include(my_courses_selected_courses_path)
      end

      it "highlights the current page in sidebar" do
        get my_courses_selected_courses_path
        expect(response.body).to include("sidebar-item active")
      end
    end
  end

  describe "DELETE /destroy" do
    let(:enrollment) { student.enrollments.first }

    context "when successfully dropping a course" do
      it "deletes the enrollment record" do
        expect {
          delete my_courses_selected_course_path(enrollment.id)
        }.to change(Enrollment, :count).by(-1)
      end

      it "redirects to selected_courses page" do
        delete my_courses_selected_course_path(enrollment.id)
        expect(response).to redirect_to(my_courses_selected_courses_path)
      end

      it "displays success message" do
        delete my_courses_selected_course_path(enrollment.id)
        follow_redirect!
        expect(response.body).to include("退课成功")
      end
    end

    context "when enrollment does not exist" do
      it "returns 404 not found" do
        delete my_courses_selected_course_path(99999)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when enrollment belongs to another student" do
      let(:other_user) { create(:user, email: "other@example.com") }
      let(:other_student) { create(:student, user: other_user) }
      let!(:other_enrollment) { create(:enrollment, student: other_student, course: course1) }

      it "does not delete the enrollment" do
        initial_count = Enrollment.count
        delete my_courses_selected_course_path(other_enrollment.id)
        expect(Enrollment.count).to eq(initial_count)
      end

      it "displays error message" do
        delete my_courses_selected_course_path(other_enrollment.id)
        follow_redirect!
        expect(response.body).to include("无权退选该课程")
      end
    end
  end
end
