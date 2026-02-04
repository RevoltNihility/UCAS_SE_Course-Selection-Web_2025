require 'rails_helper'

RSpec.describe MyCourses::SelectCoursesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/my_courses/select_courses').to route_to('my_courses/select_courses#index')
    end

    it 'routes to #create' do
      expect(post: '/my_courses/select_courses').to route_to('my_courses/select_courses#create')
    end

    it 'does not route to #new' do
      expect(get: '/my_courses/select_courses/new').not_to be_routable
    end

    it 'does not route to #show' do
      expect(get: '/my_courses/select_courses/1').not_to be_routable
    end

    it 'does not route to #edit' do
      expect(get: '/my_courses/select_courses/1/edit').not_to be_routable
    end

    it 'does not route to #update' do
      expect(patch: '/my_courses/select_courses/1').not_to be_routable
    end

    it 'does not route to #destroy' do
      expect(delete: '/my_courses/select_courses/1').not_to be_routable
    end
  end

  describe 'named routes' do
    it 'generates my_courses_select_courses_path' do
      expect(my_courses_select_courses_path).to eq('/my_courses/select_courses')
    end
  end
end
