require 'rails_helper'

RSpec.describe User, type: :model do
  describe "authentication" do
    let(:user) { build(:user, email: "test@example.com", password: "password123", password_confirmation: "password123") }

    it "has secure password functionality" do
      expect(user).to respond_to(:authenticate)
      expect(user).to respond_to(:password)
      expect(user).to respond_to(:password_confirmation)
    end

    it "authenticates with correct password" do
      user.save!
      expect(user.authenticate("password123")).to eq(user)
    end

    it "does not authenticate with incorrect password" do
      user.save!
      expect(user.authenticate("wrong_password")).to be_falsey
    end

    it "requires password on creation" do
      user.password = nil
      user.password_confirmation = nil
      expect(user).not_to be_valid
    end

    it "requires password confirmation to match" do
      user.password_confirmation = "different_password"
      expect(user).not_to be_valid
    end

    it "requires minimum password length" do
      user.password = "short"
      user.password_confirmation = "short"
      expect(user).not_to be_valid
    end
  end

  describe "associations" do
    it "has one student" do
      association = User.reflect_on_association(:student)
      expect(association.macro).to eq(:has_one)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe "role enum" do
    it "defines student, teacher, and admin roles" do
      expect(User.roles.keys).to contain_exactly("student", "teacher", "admin")
    end
  end
end
