class BusinessSettingsController < ApplicationController
  before_action :require_admin

  def show
    @setting = BusinessSetting.current
  end

  def update
    @setting = BusinessSetting.current
    if @setting.update(setting_params)
      redirect_to business_settings_path, notice: "Configuración del negocio actualizada."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def setting_params
    params.require(:business_setting).permit(
      :nombre, :telefono, :direccion, :descripcion,
      :color_primario, :color_secundario, :color_acento,
      :whatsapp_negocio, :logo
    )
  end
end
