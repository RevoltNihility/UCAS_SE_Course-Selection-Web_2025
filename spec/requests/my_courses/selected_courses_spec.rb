require 'rails_helper'

RSpec.describe "MyCourses::SelectedCourses", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/my_courses/selected_courses/index"
      expect(response).to have_http_status(:success)
    end
  end

end
