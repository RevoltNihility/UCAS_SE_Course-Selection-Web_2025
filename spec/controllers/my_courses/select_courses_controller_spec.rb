require 'rails_helper'

RSpec.describe MyCourses::SelectCoursesController, type: :controller do
  let(:user) { create(:user, role: :student) }
  let(:student) { create(:student, user: user) }

  describe 'GET #index' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns @courses' do
        course1 = create(:course, name: '课程A')
        course2 = create(:course, name: '课程B')
        get :index
        expect(assigns(:courses)).to match_array([ course1, course2 ])
      end

      it 'assigns @course_type_options' do
        get :index
        expect(assigns(:course_type_options)).to be_present
        expect(assigns(:course_type_options)).to be_an(Array)
      end

      context 'with course_name filter' do
        let!(:course1) { create(:course, name: '高等数学') }
        let!(:course2) { create(:course, name: '线性代数') }
        let!(:course3) { create(:course, name: '大学物理') }

        it 'filters courses by name' do
          get :index, params: { course_name: '数学' }
          expect(assigns(:courses)).to include(course1)
          expect(assigns(:courses)).not_to include(course3)
        end
      end

      context 'with course_type filter' do
        let!(:required_course) { create(:course, name: '必修课', course_type: :major_required) }
        let!(:elective_course) { create(:course, name: '选修课', course_type: :major_elective) }

        it 'filters courses by type' do
          get :index, params: { course_type: 'major_required' }
          expect(assigns(:courses)).to include(required_course)
          expect(assigns(:courses)).not_to include(elective_course)
        end
      end

      context 'with multiple filters' do
        let!(:course1) { create(:course, name: '高等数学', course_type: :major_required) }
        let!(:course2) { create(:course, name: '线性代数', course_type: :major_required) }
        let!(:course3) { create(:course, name: '机器学习', course_type: :major_elective) }

        it 'applies all filters' do
          get :index, params: { course_name: '数学', course_type: 'major_required' }
          expect(assigns(:courses)).to include(course1)
          expect(assigns(:courses)).not_to include(course2)
          expect(assigns(:courses)).not_to include(course3)
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        post :create, params: { course_id: 1 }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when user is logged in' do
      before do
        student # 确保 student 被创建
        session[:user_id] = user.id
      end

      it 'returns a redirect response' do
        course = create(:course)
        post :create, params: { course_id: course.id }
        expect(response).to be_redirect
      end
    end
  end
end
