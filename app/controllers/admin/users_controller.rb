module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: [:edit, :update, :destroy, :toggle_active]

    def index
      @users = User.order(:name)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "Usuario creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attrs = user_params
      attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?

      if @user.update(attrs)
        redirect_to admin_users_path, notice: "Usuario actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "No puedes eliminar tu propia cuenta."
      else
        @user.destroy
        redirect_to admin_users_path, notice: "Usuario eliminado."
      end
    end

    def toggle_active
      if @user == current_user
        redirect_to admin_users_path, alert: "No puedes desactivarte a ti mismo."
      else
        @user.update(active: !@user.active?)
        status_text = @user.active? ? "activado" : "desactivado"
        redirect_to admin_users_path, notice: "Usuario #{status_text}."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :active)
    end
  end
end
