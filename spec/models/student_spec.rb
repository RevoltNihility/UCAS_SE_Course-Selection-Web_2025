require 'rails_helper'

describe Student do
  subject(:student) { build(:student) }
  context "model validation of Student class" do
    it 'when name is nil is invalid' do
      student.name = nil
      expect(student).not_to be_valid
      expect(student.errors[:name]).to be_present
    end

    it 'when name is short than 2 is invalid' do
      student.name = 'B'
      expect(student).not_to be_valid
      expect(student.errors[:name]).to be_present
    end

    it 'when name is longer than 50 is invalid' do
      student.name = 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'
      expect(student).not_to be_valid
      expect(student.errors[:name]).to be_present
    end

    it 'when email is nil is invalid' do
      student.email = nil
      expect(student).not_to be_valid
    end

    it 'when email is not standard format is invalid' do
      student.email = 'invalid_email'
      expect(student).not_to be_valid
    end

    it 'requires unique email' do
      create(:student, email: 'dup@example.com')
      student.email = 'dup@example.com'

      expect(student).not_to be_valid
    end

    it 'requires student_id not nil' do
      student.student_id = nil
      expect(student).not_to be_valid
    end

    it 'requires student_id has standard format' do
      student.student_id = '2023M8009915034'
      expect(student).not_to be_valid
    end

    it 'requires student_id unique' do
      create(:student, student_id: '2023K8000000000')
      student.student_id = '2023K8000000000'

      expect(student).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to user" do
      association = Student.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "has many enrollments" do
      association = Student.reflect_on_association(:enrollments)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it "has many courses through enrollments" do
      association = Student.reflect_on_association(:courses)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:enrollments)
    end
  end

  describe "#enrollment_year" do
    it "returns the first 4 digits of student_id as an integer" do
      student.student_id = "2024K1234567890"
      expect(student.enrollment_year).to eq(2024)
    end

    it "works with different years" do
      student.student_id = "2023K0000000001"
      expect(student.enrollment_year).to eq(2023)
    end

    it "returns nil when student_id is nil" do
      student.student_id = nil
      expect(student.enrollment_year).to be_nil
    end

    it "returns nil when student_id is too short" do
      student.student_id = "202"
      expect(student.enrollment_year).to be_nil
    end
  end
end
