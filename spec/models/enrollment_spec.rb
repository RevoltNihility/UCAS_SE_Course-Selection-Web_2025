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
end
