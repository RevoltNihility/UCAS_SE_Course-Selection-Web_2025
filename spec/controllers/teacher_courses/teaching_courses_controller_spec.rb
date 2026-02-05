require "rails_helper"

RSpec.describe TeacherCourses::TeachingCoursesController, type: :controller do
  let(:teacher_user) { create(:user, role: :teacher) }
  let!(:teacher) { create(:teacher, user: teacher_user) }
  let(:student_user) { create(:user, role: :student) }
  let!(:student) { create(:student, user: student_user) }

  describe "GET #index" do
    context "when not logged in" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as student" do
      before do
        session[:user_id] = student_user.id
      end

      it "redirects to root with alert" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("需要教师权限")
      end
    end

    context "when logged in as teacher" do
      before do
        session[:user_id] = teacher_user.id
      end

      it "returns success" do
        get :index
        expect(response).to be_successful
      end

      it "assigns @teacher" do
        get :index
        expect(assigns(:teacher)).to eq(teacher)
      end

      it "assigns @courses with teacher's courses" do
        course1 = create(:course, name: "数据结构", code: "CS101")
        course2 = create(:course, name: "算法设计", code: "CS102")
        create(:teaching, teacher: teacher, course: course1)
        create(:teaching, teacher: teacher, course: course2)

        get :index
        expect(assigns(:courses)).to match_array([ course1, course2 ])
      end

      it "does not include courses from other teachers" do
        other_teacher = create(:teacher)
        my_course = create(:course, name: "我的课程", code: "CS101")
        other_course = create(:course, name: "其他课程", code: "CS102")
        create(:teaching, teacher: teacher, course: my_course)
        create(:teaching, teacher: other_teacher, course: other_course)

        get :index
        expect(assigns(:courses)).to eq([ my_course ])
      end
    end
  end
end
