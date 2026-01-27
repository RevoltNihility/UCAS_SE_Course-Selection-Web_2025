require 'rails_helper'

RSpec.describe "MyCourses::SelectedCourses", type: :request do
  describe "GET /index" do
    it "returns http success" do
      user = create(:user)
      create(:student, user: user)

      # 模拟用户登录
      post login_path, params: { session: { email: user.email, password: "password123" } }

      get my_courses_selected_courses_path
      expect(response).to have_http_status(:success)
    end
  end
end
