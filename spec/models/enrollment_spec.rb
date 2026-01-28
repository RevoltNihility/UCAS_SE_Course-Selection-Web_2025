require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  let(:enrollment) { build(:enrollment) }

  describe "associations" do
    it "belongs to student" do
      association = Enrollment.reflect_on_association(:student)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to course" do
      association = Enrollment.reflect_on_association(:course)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "#semester_display" do
    it "returns formatted string for fall semester" do
      enrollment.academic_year = "2024-2025"
      enrollment.semester = :fall
      expect(enrollment.semester_display).to eq("2024-2025秋")
    end

    it "returns formatted string for spring semester" do
      enrollment.academic_year = "2024-2025"
      enrollment.semester = :spring
      expect(enrollment.semester_display).to eq("2024-2025春")
    end

    it "returns formatted string for summer semester" do
      enrollment.academic_year = "2024-2025"
      enrollment.semester = :summer
      expect(enrollment.semester_display).to eq("2024-2025夏")
    end

    it "works with different academic years" do
      enrollment.academic_year = "2023-2024"
      enrollment.semester = :fall
      expect(enrollment.semester_display).to eq("2023-2024秋")
    end

    it "returns nil when academic_year is nil" do
      enrollment.academic_year = nil
      enrollment.semester = :fall
      expect(enrollment.semester_display).to be_nil
    end

    it "returns academic_year when semester is nil" do
      enrollment.academic_year = "2024-2025"
      enrollment.semester = nil
      expect(enrollment.semester_display).to eq("2024-2025")
    end
  end

  describe ".ordered" do
    let(:student) { create(:student) }
    let(:course1) { create(:course, name: "课程1") }
    let(:course2) { create(:course, name: "课程2") }
    let(:course3) { create(:course, name: "课程3") }
    let(:course4) { create(:course, name: "课程4") }
    let(:course5) { create(:course, name: "课程5") }

    before do
      # 创建不同学期和类型的选课记录
      @e1 = create(:enrollment, student: student, course: course1,
                   academic_year: "2024-2025", semester: :fall, course_type: :public_required)
      @e2 = create(:enrollment, student: student, course: course2,
                   academic_year: "2024-2025", semester: :spring, course_type: :major_elective)
      @e3 = create(:enrollment, student: student, course: course3,
                   academic_year: "2025-2026", semester: :fall, course_type: :public_elective)
      @e4 = create(:enrollment, student: student, course: course4,
                   academic_year: "2024-2025", semester: :spring, course_type: :public_required)
      @e5 = create(:enrollment, student: student, course: course5,
                   academic_year: "2023-2024", semester: :summer, course_type: :major_required)
    end

    it "sorts by academic_year DESC, semester DESC, course_type ASC" do
      ordered = Enrollment.ordered
      expect(ordered.to_a).to eq([@e3, @e4, @e2, @e1, @e5])
    end

    it "prioritizes recent academic years" do
      ordered = Enrollment.ordered
      expect(ordered.first.academic_year).to eq("2025-2026")
      expect(ordered.last.academic_year).to eq("2023-2024")
    end

    it "within same academic year, prioritizes later semesters" do
      enrollments_2024_2025 = Enrollment.ordered.select { |e| e.academic_year == "2024-2025" }
      expect(enrollments_2024_2025.first.semester).to eq("spring")
      expect(enrollments_2024_2025.last.semester).to eq("fall")
    end

    it "within same semester, sorts by course_type ascending" do
      # @e4 和 @e2 都是 2024-2025 春季学期
      # @e4 是 public_required (0), @e2 是 major_elective (3)
      ordered = Enrollment.ordered.select { |e| e.academic_year == "2024-2025" && e.semester == "spring" }
      expect(ordered.first).to eq(@e4)
      expect(ordered.last).to eq(@e2)
    end
  end
end
