require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, email: "user@example.com", password: "correct_password", password_confirmation: "correct_password") }

  describe "GET /login" do
    it "renders the login page when not logged in" do
      get login_path
      expect(response).to have_http_status(:success)
      expect(response).to render_template('sessions/new')
    end

    it "redirects to my courses if already logged in" do
      # 先登录
      post login_path, params: { session: { email: user.email, password: "correct_password" } }
      # 再次访问登录页面应该重定向
      get login_path
      expect(response).to redirect_to(my_courses_selected_courses_path)
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "logs in the user and stores user_id in session" do
        post login_path, params: { session: { email: user.email, password: "correct_password" } }

        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(my_courses_selected_courses_path)
        expect(flash[:success]).to eq("登录成功！")
      end
    end

    context "with invalid password" do
      it "re-renders the login page with error message" do
        post login_path, params: { session: { email: user.email, password: "wrong_password" } }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template('sessions/new')
        expect(response.body).to include("登录失败")
      end
    end

    context "with non-existent email" do
      it "re-renders the login page with error message" do
        post login_path, params: { session: { email: "nonexistent@example.com", password: "any_password" } }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template('sessions/new')
        expect(response.body).to include("登录失败")
      end
    end

    context "with empty credentials" do
      it "re-renders the login page with error message" do
        post login_path, params: { session: { email: "", password: "" } }

        expect(session[:user_id]).to be_nil
        expect(response).to render_template('sessions/new')
        expect(response.body).to include("登录失败")
      end
    end
  end

  describe "DELETE /logout" do
    it "logs out the user and clears session" do
      # 先登录
      post login_path, params: { session: { email: user.email, password: "correct_password" } }
      expect(session[:user_id]).to eq(user.id)

      # 登出
      delete logout_path
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
    end
  end
end
