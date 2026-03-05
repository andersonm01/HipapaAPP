class ApplicationController < ActionController::Base
  before_action :require_login

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Debes iniciar sesión para continuar."
    end
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Solo los administradores pueden acceder a esta sección."
    end
  end

  def require_admin_or_supervisor
    unless current_user&.admin? || current_user&.supervisor?
      redirect_to root_path, alert: "No tienes permisos para acceder a esta sección."
    end
  end
end
