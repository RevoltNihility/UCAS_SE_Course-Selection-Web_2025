class SessionsController < ApplicationController
  include SessionsHelper
  def new
    logged_in? ? (redirect_to root_path) : (render :new)
  end

  def create
    user = Student.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      flash.now[:success] = "登录成功，跳转至主页！"
      redirect_to root_path
    else
      flash.now[:danger] = "登录失败，用户名/密码错误！"
      render :new
    end
  end

  def destroy
    log_out
    redirect_to login_path
  end
end
