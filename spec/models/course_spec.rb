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

    it 'sets course_type to major_required by default' do
      expect(course.course_type).to eq('major_required')
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

  describe 'enums' do
    it 'defines course_type enum' do
      expect(Course.course_types).to eq({
        'public_required' => 0,
        'public_elective' => 1,
        'major_required' => 2,
        'major_elective' => 3
      })
    end

    it 'allows setting course_type to public_required' do
      course = Course.create!(name: '公共必修课', code: 'PUB001', credits: 3, course_type: :public_required)
      expect(course.public_required?).to be true
    end

    it 'allows setting course_type to public_elective' do
      course = Course.create!(name: '公共选修课', code: 'PUB002', credits: 2, course_type: :public_elective)
      expect(course.public_elective?).to be true
    end

    it 'allows setting course_type to major_required' do
      course = Course.create!(name: '专业必修课', code: 'MAJ001', credits: 3, course_type: :major_required)
      expect(course.major_required?).to be true
    end

    it 'allows setting course_type to major_elective' do
      course = Course.create!(name: '专业选修课', code: 'MAJ002', credits: 2, course_type: :major_elective)
      expect(course.major_elective?).to be true
    end
  end

  describe 'validations' do
    it 'validates max_enrollment is greater than 0' do
      course = Course.new(name: '测试课程', code: 'TEST001', credits: 3, max_enrollment: 0)
      expect(course).not_to be_valid
      expect(course.errors[:max_enrollment]).to be_present
    end

    it 'validates max_enrollment is not negative' do
      course = Course.new(name: '测试课程', code: 'TEST001', credits: 3, max_enrollment: -1)
      expect(course).not_to be_valid
      expect(course.errors[:max_enrollment]).to be_present
    end

    it 'allows positive max_enrollment' do
      course = Course.new(name: '测试课程', code: 'TEST001', credits: 3, max_enrollment: 50)
      expect(course).to be_valid
    end
  end

  describe '#enrolled_count' do
    let(:course) { create(:course) }
    let(:student1) { create(:student) }
    let(:student2) { create(:student) }
    let(:student3) { create(:student) }

    it 'returns 0 when no students enrolled' do
      expect(course.enrolled_count).to eq(0)
    end

    it 'returns correct count when students are enrolled' do
      create(:enrollment, course: course, student: student1)
      create(:enrollment, course: course, student: student2)
      expect(course.enrolled_count).to eq(2)
    end

    it 'updates count when new enrollment is added' do
      create(:enrollment, course: course, student: student1)
      expect(course.enrolled_count).to eq(1)

      create(:enrollment, course: course, student: student2)
      expect(course.enrolled_count).to eq(2)
    end
  end

  describe '#full?' do
    let(:course) { create(:course, max_enrollment: 2) }
    let(:student1) { create(:student) }
    let(:student2) { create(:student) }
    let(:student3) { create(:student) }

    it 'returns false when course has available slots' do
      expect(course.full?).to be false
    end

    it 'returns false when course is partially filled' do
      create(:enrollment, course: course, student: student1)
      expect(course.full?).to be false
    end

    it 'returns true when course is exactly full' do
      create(:enrollment, course: course, student: student1)
      create(:enrollment, course: course, student: student2)
      expect(course.full?).to be true
    end

    it 'returns true when course is over capacity' do
      course.update!(max_enrollment: 1)
      create(:enrollment, course: course, student: student1)
      create(:enrollment, course: course, student: student2)
      expect(course.full?).to be true
    end
  end

  describe '.filter_for_selection' do
    let!(:course1) { create(:course, name: '高等数学', course_type: :major_required) }
    let!(:course2) { create(:course, name: '线性代数', course_type: :major_required) }
    let!(:course3) { create(:course, name: '机器学习', course_type: :major_elective) }
    let!(:course4) { create(:course, name: '大学物理', course_type: :major_required) }

    context 'without any filters' do
      it 'returns all courses ordered by name' do
        courses = Course.filter_for_selection(course_name: nil, course_type: nil)
        expect(courses.count).to eq(4)
        expect(courses.first.name).to eq('大学物理')
      end
    end

    context 'with course_name filter' do
      it 'filters courses by name (fuzzy search)' do
        courses = Course.filter_for_selection(course_name: '数', course_type: nil)
        expect(courses).to include(course1, course2)
        expect(courses).not_to include(course3, course4)
      end

      it 'returns empty when no match' do
        courses = Course.filter_for_selection(course_name: '化学', course_type: nil)
        expect(courses).to be_empty
      end

      it 'handles empty string as no filter' do
        courses = Course.filter_for_selection(course_name: '', course_type: nil)
        expect(courses.count).to eq(4)
      end
    end

    context 'with course_type filter' do
      it 'filters courses by type' do
        courses = Course.filter_for_selection(course_name: nil, course_type: 'major_required')
        expect(courses).to include(course1, course2, course4)
        expect(courses).not_to include(course3)
      end

      it 'handles elective type' do
        courses = Course.filter_for_selection(course_name: nil, course_type: 'major_elective')
        expect(courses).to include(course3)
        expect(courses).not_to include(course1, course2, course4)
      end

      it 'handles empty string as no filter' do
        courses = Course.filter_for_selection(course_name: nil, course_type: '')
        expect(courses.count).to eq(4)
      end
    end

    context 'with both filters' do
      it 'applies both course_name and course_type filters' do
        courses = Course.filter_for_selection(course_name: '数', course_type: 'major_required')
        expect(courses).to include(course1, course2)
        expect(courses).not_to include(course3, course4)
      end

      it 'returns empty when no courses match both conditions' do
        courses = Course.filter_for_selection(course_name: '数学', course_type: 'major_elective')
        expect(courses).to be_empty
      end
    end
  end
end
