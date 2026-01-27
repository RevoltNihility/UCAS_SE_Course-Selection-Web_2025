class SessionsController < ApplicationController
  include SessionsHelper
  def new
    logged_in? ? (redirect_to root_path) : (render :new)
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      flash[:success] = "登录成功！"
      redirect_back_or(my_courses_selected_courses_path)
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
