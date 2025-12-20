module SessionsHelper
  def log_in(user)
    session[:student_id] = user.id
  end

  def current_user
    @current_user ||= Student.find_by(id: session[:student_id])
  end

  def logged_in?
    !!current_user
  end

  def log_out
    session.delete(:student_id)
    @current_user = nil
  end
end
