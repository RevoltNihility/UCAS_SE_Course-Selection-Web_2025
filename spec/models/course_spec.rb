require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'database columns and default values' do
    let(:course) { Course.create!(name: '测试课程', code: 'TEST001', credits: 3) }

    it 'has max_enrollment column' do
      expect(course).to respond_to(:max_enrollment)
    end

    it 'has course_type column' do
      expect(course).to respond_to(:course_type)
    end

    it 'has schedule_time column' do
      expect(course).to respond_to(:schedule_time)
    end

    it 'sets max_enrollment to 100 by default' do
      expect(course.max_enrollment).to eq(100)
    end

    it 'sets course_type to 0 by default' do
      expect(course.course_type).to eq(0)
    end

    it 'allows schedule_time to be nil' do
      expect(course.schedule_time).to be_nil
    end
  end

  describe 'associations' do
    it 'has many enrollments' do
      association = Course.reflect_on_association(:enrollments)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many students through enrollments' do
      association = Course.reflect_on_association(:students)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:enrollments)
    end
  end
end
