require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:student) { Student.create!(email: "user@example.com", password: "correct_password", password_confirmation: "correct_password", name: "Test", student_id: "2023K8009915034") }

  describe "GET /login" do
    it "renders the login page when not logged in" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to root if already logged in" do
      post login_path, params: { session: { email: student.email, password: "correct_password", password_confirmation: "correct_password" } }
      get login_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "logs in and redirects to root" do
        get login_path
        expect(response).to render_template('sessions/new')

        post login_path, params: { session: { email: "user@example.com", password: "correct_password" } }
        expect(session[:student_id]).to eq(student.id)   # 检查 session 是否被设置
        expect(response).to redirect_to(root_path)
        expect(flash[:success]).to be_present
      end
    end

    context "with invalid credentials" do
      it "re-renders the login page with a flash error" do
        get login_path
        expect(response).to render_template('sessions/new')

        post login_path, params: { session: { email: "", password: "" } }
        expect(response).to render_template('sessions/new')

        expect(flash[:danger]).to be_present

        get login_path
        expect(flash[:danger]).to be_nil
      end
    end
  end
end
