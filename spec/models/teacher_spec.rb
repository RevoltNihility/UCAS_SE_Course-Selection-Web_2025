require "rails_helper"

describe Teacher do
  subject(:teacher) { build(:teacher) }

  context "model validation of Teacher class" do
    it "when name is nil is invalid" do
      teacher.name = nil
      expect(teacher).not_to be_valid
      expect(teacher.errors[:name]).to be_present
    end

    it "when name is shorter than 2 is invalid" do
      teacher.name = "李"
      expect(teacher).not_to be_valid
      expect(teacher.errors[:name]).to be_present
    end

    it "when name is longer than 50 is invalid" do
      teacher.name = "李" * 51
      expect(teacher).not_to be_valid
      expect(teacher.errors[:name]).to be_present
    end

    it "when email is nil is invalid" do
      teacher.email = nil
      expect(teacher).not_to be_valid
    end

    it "when email is not standard format is invalid" do
      teacher.email = "invalid_email"
      expect(teacher).not_to be_valid
    end

    it "requires unique email" do
      create(:teacher, email: "dup@example.com")
      teacher.email = "dup@example.com"

      expect(teacher).not_to be_valid
    end

    it "requires teacher_id not nil" do
      teacher.teacher_id = nil
      expect(teacher).not_to be_valid
    end

    it "requires teacher_id has standard format" do
      teacher.teacher_id = "T0000001"
      expect(teacher).not_to be_valid
    end

    it "requires teacher_id with 8 digits after T" do
      teacher.teacher_id = "T000000001"
      expect(teacher).not_to be_valid
    end

    it "requires teacher_id starts with T" do
      teacher.teacher_id = "00000001"
      expect(teacher).not_to be_valid
    end

    it "requires teacher_id unique" do
      create(:teacher, teacher_id: "T00000001")
      teacher.teacher_id = "T00000001"

      expect(teacher).not_to be_valid
    end

    it "accepts valid teacher_id" do
      teacher.teacher_id = "T00000001"
      expect(teacher).to be_valid
    end
  end

  describe "associations" do
    it "belongs to user" do
      association = Teacher.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "has many teachings" do
      association = Teacher.reflect_on_association(:teachings)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it "has many courses through teachings" do
      association = Teacher.reflect_on_association(:courses)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:teachings)
    end
  end
end
