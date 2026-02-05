require "rails_helper"

RSpec.describe "MyCourses::CreditsSummary", type: :request do
  let(:user) { create(:user) }
  let(:student) { create(:student, user: user) }

  before do
    # 模拟用户登录
    post login_path, params: { session: { email: user.email, password: "password123" } }
  end

  describe "GET /my_courses/credits_summary" do
    context "when student has no enrollments" do
      it "returns http success" do
        get my_courses_credits_summary_index_path
        expect(response).to have_http_status(:success)
      end

      it "displays zero credits for all categories" do
        get my_courses_credits_summary_index_path
        expect(response.body).to include("公共必修课")
        expect(response.body).to include("公共选修课")
        expect(response.body).to include("专业必修课")
        expect(response.body).to include("专业选修课")
        expect(response.body).to include("总学分")
      end

      it "displays credit requirements" do
        get my_courses_credits_summary_index_path
        expect(response.body).to include("20") # 公共必修课要求
        expect(response.body).to include("15") # 公共选修课要求
        expect(response.body).to include("12") # 专业选修课要求
        expect(response.body).to include("62") # 总学分要求
      end
    end

    context "when student has enrollments" do
      let!(:course1) { create(:course, credits: 3) }
      let!(:course2) { create(:course, credits: 2) }
      let!(:course3) { create(:course, credits: 4) }
      let!(:course4) { create(:course, credits: 2.5) }

      let!(:enrollment1) { create(:enrollment, student: student, course: course1, course_type: :public_required) }
      let!(:enrollment2) { create(:enrollment, student: student, course: course2, course_type: :public_elective) }
      let!(:enrollment3) { create(:enrollment, student: student, course: course3, course_type: :major_required) }
      let!(:enrollment4) { create(:enrollment, student: student, course: course4, course_type: :major_elective) }

      it "calculates credits correctly for each category" do
        get my_courses_credits_summary_index_path
        expect(response).to have_http_status(:success)

        # 验证统计数据在响应中
        expect(assigns(:public_required_credits)).to eq(3.0)
        expect(assigns(:public_elective_credits)).to eq(2.0)
        expect(assigns(:major_required_credits)).to eq(4.0)
        expect(assigns(:major_elective_credits)).to eq(2.5)
        expect(assigns(:total_credits)).to eq(11.5)
      end

      it "displays the calculated credits" do
        get my_courses_credits_summary_index_path
        expect(response.body).to include("3.0") # 公共必修课已修
        expect(response.body).to include("2.0") # 公共选修课已修
        expect(response.body).to include("4.0") # 专业必修课已修
        expect(response.body).to include("2.5") # 专业选修课已修
        expect(response.body).to include("11.5") # 总学分已修
      end
    end

    context "when credits meet requirements" do
      let!(:course1) { create(:course, credits: 20) }
      let!(:course2) { create(:course, credits: 15) }
      let!(:course3) { create(:course, credits: 15) }
      let!(:course4) { create(:course, credits: 12) }

      let!(:enrollment1) { create(:enrollment, student: student, course: course1, course_type: :public_required) }
      let!(:enrollment2) { create(:enrollment, student: student, course: course2, course_type: :public_elective) }
      let!(:enrollment3) { create(:enrollment, student: student, course: course3, course_type: :major_required) }
      let!(:enrollment4) { create(:enrollment, student: student, course: course4, course_type: :major_elective) }

      it "does not highlight credits in red when requirements are met" do
        get my_courses_credits_summary_index_path
        # 检查是否没有 insufficient 类（用于标记未满足的学分）
        doc = Nokogiri::HTML(response.body)
        insufficient_cells = doc.css(".insufficient")
        expect(insufficient_cells.size).to eq(0)
      end
    end

    context "when credits do not meet requirements" do
      let!(:course1) { create(:course, credits: 10) }
      let!(:enrollment1) { create(:enrollment, student: student, course: course1, course_type: :public_required) }

      it "highlights insufficient credits in red" do
        get my_courses_credits_summary_index_path
        # 检查是否有 insufficient 类标记未满足的学分
        doc = Nokogiri::HTML(response.body)
        insufficient_cells = doc.css(".insufficient")
        expect(insufficient_cells.size).to be > 0
      end
    end

    context "when user is not logged in" do
      before do
        delete logout_path
      end

      it "redirects to login page" do
        get my_courses_credits_summary_index_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
