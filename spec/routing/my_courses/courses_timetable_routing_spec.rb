require 'rails_helper'

RSpec.describe MyCourses::CoursesTimetableController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/my_courses/courses_timetable').to route_to('my_courses/courses_timetable#index')
    end

    it 'does not route to #create' do
      expect(post: '/my_courses/courses_timetable').not_to be_routable
    end

    it 'does not route to #new' do
      expect(get: '/my_courses/courses_timetable/new').not_to be_routable
    end

    it 'does not route to #show' do
      expect(get: '/my_courses/courses_timetable/1').not_to be_routable
    end

    it 'does not route to #edit' do
      expect(get: '/my_courses/courses_timetable/1/edit').not_to be_routable
    end

    it 'does not route to #update' do
      expect(patch: '/my_courses/courses_timetable/1').not_to be_routable
    end

    it 'does not route to #destroy' do
      expect(delete: '/my_courses/courses_timetable/1').not_to be_routable
    end
  end

  describe 'named routes' do
    it 'generates my_courses_courses_timetable_index_path' do
      expect(my_courses_courses_timetable_index_path).to eq('/my_courses/courses_timetable')
    end
  end
end
