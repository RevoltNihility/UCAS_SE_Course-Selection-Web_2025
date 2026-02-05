require 'rails_helper'

RSpec.describe MyCourses::CoursesTimetableHelper, type: :helper do
  describe '#course_color' do
    it 'returns a valid color for index 0' do
      color = helper.course_color(0)
      expect(color).to match(/^#[0-9A-Fa-f]{6}$/)
    end

    it 'returns different colors for different indices' do
      color1 = helper.course_color(0)
      color2 = helper.course_color(1)
      expect(color1).not_to eq(color2)
    end

    it 'cycles through colors when index exceeds color array length' do
      color1 = helper.course_color(0)
      # 假设有10种颜色，第10个应该和第0个相同
      color11 = helper.course_color(10)
      expect(color1).to eq(color11)
    end
  end

  describe '#build_timetable_data' do
    let(:course1) { create(:course, name: "高等数学", schedule_time: "1:1-2,3:3-4") }
    let(:course2) { create(:course, name: "线性代数", schedule_time: "2:1-2") }
    let(:course3) { create(:course, name: "数据结构", schedule_time: "5:5-7") }
    let(:course4) { create(:course, name: "物理", schedule_time: "") }

    context 'with courses having schedule times' do
      it 'returns a hash with day and period keys' do
        courses = [course1, course2]
        timetable = helper.build_timetable_data(courses)

        expect(timetable).to be_a(Hash)
      end

      it 'correctly maps course to its time slots' do
        courses = [course1]
        timetable = helper.build_timetable_data(courses)

        # 周一1-2节应该有高等数学
        expect(timetable[1][1][:course]).to eq(course1)
        expect(timetable[1][2][:course]).to eq(course1)

        # 周三3-4节应该有高等数学
        expect(timetable[3][3][:course]).to eq(course1)
        expect(timetable[3][4][:course]).to eq(course1)
      end

      it 'assigns colors to courses' do
        courses = [course1, course2]
        timetable = helper.build_timetable_data(courses)

        # 检查课程有颜色
        expect(timetable[1][1][:color]).to be_present
        expect(timetable[2][1][:color]).to be_present
      end

      it 'assigns different colors to different courses' do
        courses = [course1, course2]
        timetable = helper.build_timetable_data(courses)

        color1 = timetable[1][1][:color]
        color2 = timetable[2][1][:color]
        expect(color1).not_to eq(color2)
      end

      it 'handles multiple courses in different time slots' do
        courses = [course1, course2, course3]
        timetable = helper.build_timetable_data(courses)

        expect(timetable[1][1][:course]).to eq(course1)
        expect(timetable[2][1][:course]).to eq(course2)
        expect(timetable[5][5][:course]).to eq(course3)
      end
    end

    context 'with empty courses array' do
      it 'returns an empty hash' do
        timetable = helper.build_timetable_data([])
        expect(timetable).to eq({})
      end
    end

    context 'with courses having no schedule time' do
      it 'skips courses without schedule_time' do
        courses = [course4]
        timetable = helper.build_timetable_data(courses)
        expect(timetable).to eq({})
      end

      it 'includes only courses with valid schedule_time' do
        courses = [course1, course4]
        timetable = helper.build_timetable_data(courses)

        # 应该只有course1的时间
        expect(timetable[1][1][:course]).to eq(course1)
        expect(timetable.values.flat_map(&:values).map { |v| v[:course] }.uniq).to eq([course1])
      end
    end

    context 'with courses having continuous periods' do
      it 'marks the first period as span_start' do
        courses = [course1]
        timetable = helper.build_timetable_data(courses)

        # 1-2节，第1节应该是span_start
        expect(timetable[1][1][:span_start]).to be true
        expect(timetable[1][2][:span_start]).to be false
      end

      it 'calculates correct rowspan for continuous periods' do
        courses = [course3] # 5-7节，共3节
        timetable = helper.build_timetable_data(courses)

        expect(timetable[5][5][:rowspan]).to eq(3)
      end
    end
  end
end
