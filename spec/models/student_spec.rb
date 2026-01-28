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

  describe "#enrollments_filtered" do
    let(:student) { create(:student) }
    let(:course1) { create(:course, name: "高等数学") }
    let(:course2) { create(:course, name: "线性代数") }
    let(:course3) { create(:course, name: "数据结构") }
    let(:course4) { create(:course, name: "计算机网络") }

    before do
      create(:enrollment, student: student, course: course1,
             academic_year: "2024-2025", semester: :fall)
      create(:enrollment, student: student, course: course2,
             academic_year: "2024-2025", semester: :spring)
      create(:enrollment, student: student, course: course3,
             academic_year: "2025-2026", semester: :fall)
      create(:enrollment, student: student, course: course4,
             academic_year: "2023-2024", semester: :spring)
    end

    context "without any filters" do
      it "returns all enrollments ordered" do
        result = student.enrollments_filtered
        expect(result.count).to eq(4)
        # 验证排序:2025-2026秋 > 2024-2025春 > 2024-2025秋 > 2023-2024春
        expect(result.first.course.name).to eq("数据结构")
        expect(result.last.course.name).to eq("计算机网络")
      end
    end

    context "filtering by semester only" do
      it "returns only enrollments from specified semester" do
        result = student.enrollments_filtered(semester: "2024-2025秋")
        expect(result.count).to eq(1)
        expect(result.first.course.name).to eq("高等数学")
      end

      it "returns empty when no match" do
        result = student.enrollments_filtered(semester: "2022-2023秋")
        expect(result).to be_empty
      end

      it "handles spring semester" do
        result = student.enrollments_filtered(semester: "2024-2025春")
        expect(result.count).to eq(1)
        expect(result.first.course.name).to eq("线性代数")
      end
    end

    context "filtering by course name only" do
      it "returns enrollments with matching course names (fuzzy search)" do
        result = student.enrollments_filtered(course_name: "数")
        expect(result.count).to eq(3)
        expect(result.map { |e| e.course.name }).to contain_exactly("高等数学", "线性代数", "数据结构")
      end

      it "is case sensitive" do
        result = student.enrollments_filtered(course_name: "计算机")
        expect(result.count).to eq(1)
        expect(result.first.course.name).to eq("计算机网络")
      end

      it "returns empty when no match" do
        result = student.enrollments_filtered(course_name: "物理")
        expect(result).to be_empty
      end
    end

    context "filtering by both semester and course name" do
      it "returns enrollments matching both conditions" do
        result = student.enrollments_filtered(semester: "2024-2025秋", course_name: "数学")
        expect(result.count).to eq(1)
        expect(result.first.course.name).to eq("高等数学")
      end

      it "returns empty when semester matches but course name doesn't" do
        result = student.enrollments_filtered(semester: "2024-2025秋", course_name: "物理")
        expect(result).to be_empty
      end

      it "returns empty when course name matches but semester doesn't" do
        result = student.enrollments_filtered(semester: "2022-2023秋", course_name: "数学")
        expect(result).to be_empty
      end
    end

    context "with nil or empty parameters" do
      it "treats nil semester as no filter" do
        result = student.enrollments_filtered(semester: nil, course_name: "数学")
        expect(result.count).to eq(1)
        expect(result.first.course.name).to eq("高等数学")
      end

      it "treats empty string semester as no filter" do
        result = student.enrollments_filtered(semester: "", course_name: "数学")
        expect(result.count).to eq(1)
      end

      it "treats nil course_name as no filter" do
        result = student.enrollments_filtered(semester: "2024-2025秋", course_name: nil)
        expect(result.count).to eq(1)
      end

      it "treats empty string course_name as no filter" do
        result = student.enrollments_filtered(semester: "2024-2025秋", course_name: "")
        expect(result.count).to eq(1)
      end
    end
  end

  describe "#available_semesters" do
    it "returns all semesters from enrollment year to current year" do
      student.student_id = "2024K1234567890"
      # 假设当前是 2026 年
      allow(Date).to receive(:today).and_return(Date.new(2026, 3, 1))

      semesters = student.available_semesters
      expect(semesters).to include("2024-2025秋", "2024-2025春", "2025-2026秋", "2025-2026春")
      expect(semesters.length).to eq(4)
    end

    it "returns semesters in chronological order" do
      student.student_id = "2024K1234567890"
      allow(Date).to receive(:today).and_return(Date.new(2025, 6, 1))

      semesters = student.available_semesters
      expect(semesters).to eq(["2024-2025秋", "2024-2025春"])
    end

    it "handles newly enrolled students (same year as current)" do
      student.student_id = "2026K1234567890"
      allow(Date).to receive(:today).and_return(Date.new(2026, 3, 1))

      semesters = student.available_semesters
      expect(semesters).to eq(["2025-2026秋", "2025-2026春"])
    end

    it "includes current semester when in fall" do
      student.student_id = "2024K1234567890"
      allow(Date).to receive(:today).and_return(Date.new(2025, 10, 1))

      semesters = student.available_semesters
      expect(semesters).to include("2025-2026秋")
    end

    it "returns empty array when enrollment_year is nil" do
      student.student_id = nil

      semesters = student.available_semesters
      expect(semesters).to eq([])
    end

    it "handles students enrolled many years ago" do
      student.student_id = "2020K1234567890"
      allow(Date).to receive(:today).and_return(Date.new(2023, 6, 1))

      semesters = student.available_semesters
      expect(semesters.length).to eq(6)  # 2020-2021秋春, 2021-2022秋春, 2022-2023秋春
      expect(semesters.first).to eq("2020-2021秋")
      expect(semesters.last).to eq("2022-2023春")
    end
  end
end
