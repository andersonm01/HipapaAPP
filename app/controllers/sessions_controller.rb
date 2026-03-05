class SessionsController < ApplicationController
  skip_before_action :require_login
  layout 'sessions'

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      if user.active?
        session[:user_id] = user.id
        redirect_to root_path, notice: "Bienvenido, #{user.name}!"
      else
        flash.now[:alert] = "Tu cuenta está desactivada. Contacta al administrador."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Email o contraseña incorrectos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Sesión cerrada."
  end

  def omniauth
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)

    if user.nil?
      redirect_to login_path, alert: "Acceso denegado. Contacta al administrador para crear tu cuenta."
    elsif !user.active?
      redirect_to login_path, alert: "Tu cuenta está desactivada. Contacta al administrador."
    else
      user.update(provider: auth.provider, uid: auth.uid) if user.provider.blank?
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bienvenido, #{user.name}!"
    end
  end

  def omniauth_failure
    redirect_to login_path, alert: "Autenticación con Google fallida. Intenta de nuevo."
  end
end
