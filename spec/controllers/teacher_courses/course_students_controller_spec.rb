require "rails_helper"

RSpec.describe TeacherCourses::CourseStudentsController, type: :controller do
  let(:teacher_user) { create(:user, role: :teacher) }
  let!(:teacher) { create(:teacher, user: teacher_user) }
  let(:student_user) { create(:user, role: :student) }
  let!(:student) { create(:student, user: student_user) }
  let(:course) { create(:course) }

  describe "GET #show" do
    context "when not logged in" do
      it "redirects to login page" do
        get :show, params: { id: course.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in as student" do
      before do
        session[:user_id] = student_user.id
      end

      it "redirects to root with alert" do
        get :show, params: { id: course.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("需要教师权限")
      end
    end

    context "when logged in as teacher" do
      before do
        session[:user_id] = teacher_user.id
      end

      it "returns success" do
        get :show, params: { id: course.id }
        expect(response).to be_successful
      end

      it "assigns @course" do
        get :show, params: { id: course.id }
        expect(assigns(:course)).to eq(course)
      end

      it "assigns @students with enrolled students" do
        student1 = create(:student, name: "张三", student_id: "2024K0000000001")
        student2 = create(:student, name: "李四", student_id: "2024K0000000002")
        create(:enrollment, student: student1, course: course)
        create(:enrollment, student: student2, course: course)

        get :show, params: { id: course.id }
        expect(assigns(:students)).to match_array([ student1, student2 ])
      end

      it "does not include students from other courses" do
        other_course = create(:course, name: "其他课程", code: "CS999")
        enrolled_student = create(:student, name: "选课学生", student_id: "2024K0000000001")
        other_student = create(:student, name: "其他学生", student_id: "2024K0000000002")
        create(:enrollment, student: enrolled_student, course: course)
        create(:enrollment, student: other_student, course: other_course)

        get :show, params: { id: course.id }
        expect(assigns(:students)).to eq([ enrolled_student ])
      end
    end
  end
end
