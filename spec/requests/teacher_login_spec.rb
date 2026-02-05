require "rails_helper"

RSpec.describe "Teacher login flow", type: :request do
  let(:teacher_user) { create(:user, email: "teacher@test.com", password: "password123", role: :teacher) }
  let!(:teacher) { create(:teacher, user: teacher_user, email: "teacher@test.com") }
  let(:student_user) { create(:user, email: "student@test.com", password: "password123", role: :student) }
  let!(:student) { create(:student, user: student_user, email: "student@test.com") }

  describe "teacher login redirect" do
    it "redirects teacher to teaching courses page after login" do
      post login_path, params: {
        session: {
          email: "teacher@test.com",
          password: "password123"
        }
      }

      expect(response).to redirect_to(teacher_courses_teaching_courses_path)
      follow_redirect!
      expect(response).to be_successful
      expect(response.body).to include("我教授的课程")
    end

    it "redirects already logged in teacher to teaching courses page" do
      # 先登录
      post login_path, params: {
        session: {
          email: "teacher@test.com",
          password: "password123"
        }
      }

      # 再次访问登录页
      get login_path
      expect(response).to redirect_to(teacher_courses_teaching_courses_path)
    end
  end

  describe "student login redirect" do
    it "redirects student to selected courses page after login" do
      post login_path, params: {
        session: {
          email: "student@test.com",
          password: "password123"
        }
      }

      expect(response).to redirect_to(my_courses_selected_courses_path)
      follow_redirect!
      expect(response).to be_successful
      expect(response.body).to include("已选课程")
    end

    it "redirects already logged in student to selected courses page" do
      # 先登录
      post login_path, params: {
        session: {
          email: "student@test.com",
          password: "password123"
        }
      }

      # 再次访问登录页
      get login_path
      expect(response).to redirect_to(my_courses_selected_courses_path)
    end
  end

  describe "teacher access control" do
    before do
      post login_path, params: {
        session: {
          email: "teacher@test.com",
          password: "password123"
        }
      }
    end

    it "allows teacher to access teaching courses page" do
      get teacher_courses_teaching_courses_path
      expect(response).to be_successful
    end

    it "allows teacher to access course students page" do
      course = create(:course)
      get teacher_courses_course_student_path(course)
      expect(response).to be_successful
    end
  end

  describe "student cannot access teacher pages" do
    before do
      post login_path, params: {
        session: {
          email: "student@test.com",
          password: "password123"
        }
      }
    end

    it "redirects student from teaching courses page" do
      get teacher_courses_teaching_courses_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("需要教师权限")
    end

    it "redirects student from course students page" do
      course = create(:course)
      get teacher_courses_course_student_path(course)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("需要教师权限")
    end
  end
end
