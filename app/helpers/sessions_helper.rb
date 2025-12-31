module SessionsHelper
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def redirect_back_or(default_url)
    redirect_to(session[:forwarding_url] || default_url)
    session.delete(:forwarding_url)
  end

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
