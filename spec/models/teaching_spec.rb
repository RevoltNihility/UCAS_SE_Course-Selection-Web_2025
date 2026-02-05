require "rails_helper"

RSpec.describe Teaching, type: :model do
  let(:teaching) { build(:teaching) }

  describe "associations" do
    it "belongs to teacher" do
      association = Teaching.reflect_on_association(:teacher)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to course" do
      association = Teaching.reflect_on_association(:course)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "requires unique teacher_id and course_id combination" do
      teacher = create(:teacher)
      course = create(:course)
      create(:teaching, teacher: teacher, course: course)

      duplicate_teaching = build(:teaching, teacher: teacher, course: course)
      expect(duplicate_teaching).not_to be_valid
    end

    it "allows same teacher to teach different courses" do
      teacher = create(:teacher)
      course1 = create(:course, name: "课程1", code: "CS101")
      course2 = create(:course, name: "课程2", code: "CS102")

      create(:teaching, teacher: teacher, course: course1)
      teaching2 = build(:teaching, teacher: teacher, course: course2)

      expect(teaching2).to be_valid
    end

    it "allows different teachers to teach same course" do
      teacher1 = create(:teacher)
      teacher2 = create(:teacher)
      course = create(:course)

      create(:teaching, teacher: teacher1, course: course)
      teaching2 = build(:teaching, teacher: teacher2, course: course)

      expect(teaching2).to be_valid
    end
  end
end
