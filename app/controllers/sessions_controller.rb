class SessionsController < ApplicationController
  include SessionsHelper
  def new
    if logged_in?
      redirect_to redirect_path_for_user(current_user)
    else
      render :new
    end
  end

  def create
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      flash[:success] = "登录成功！"
      redirect_back_or(redirect_path_for_user(user))
    else
      flash.now[:danger] = "登录失败，用户名/密码错误！"
      render :new
    end
  end

  def destroy
    log_out
    flash[:success] = "已成功退出登录"
    redirect_to root_path
  end

  private

  def redirect_path_for_user(user)
    user.teacher? ? teacher_courses_teaching_courses_path : my_courses_selected_courses_path
  end
end
