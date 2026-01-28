require 'rails_helper'

RSpec.describe MyCourses::SelectedCoursesHelper, type: :helper do
  describe "#format_class_hours_credits" do
    it "formats class hours and credits with slash separator" do
      course = build(:course, class_hours: 48, credits: 3)
      expect(helper.format_class_hours_credits(course)).to eq("48/3")
    end

    it "handles different values" do
      course = build(:course, class_hours: 64, credits: 4)
      expect(helper.format_class_hours_credits(course)).to eq("64/4")
    end

    it "returns dash when class_hours is nil" do
      course = build(:course, class_hours: nil, credits: 3)
      expect(helper.format_class_hours_credits(course)).to eq("-/3")
    end

    it "returns dash when credits is nil" do
      course = build(:course, class_hours: 48, credits: nil)
      expect(helper.format_class_hours_credits(course)).to eq("48/-")
    end

    it "returns dash/dash when both are nil" do
      course = build(:course, class_hours: nil, credits: nil)
      expect(helper.format_class_hours_credits(course)).to eq("-/-")
    end
  end
end
